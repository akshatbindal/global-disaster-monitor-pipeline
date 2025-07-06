import apache_beam as beam
from apache_beam.options.pipeline_options import PipelineOptions
from apache_beam.io import ReadFromPubSub
from apache_beam.io.gcp.bigquery import WriteToBigQuery
from apache_beam.io.gcp.bigquery import ReadFromBigQuery
import json
import requests
import os
from datetime import datetime, timezone
import logging

class DisasterEventProcessor(beam.DoFn):
    """Process and enrich disaster events"""
    
    def __init__(self, geocoding_api_key, project_id, dataset_id):
        self.geocoding_api_key = geocoding_api_key
        self.project_id = project_id
        self.dataset_id = dataset_id
        
    def setup(self):
        # Initialize BigQuery client for demographics lookup
        from google.cloud import bigquery
        self.bq_client = bigquery.Client(project=self.project_id)
        
    def process(self, element):
        try:
            # Parse the Pub/Sub message
            event = json.loads(element.decode('utf-8'))
            
            # Geocode the location
            address = self.geocode_location(event['latitude'], event['longitude'])
            event['address'] = address
            
            # Enrich with demographics data
            demographics = self.get_demographics(event['latitude'], event['longitude'])
            event['population_density'] = demographics.get('population_density')
            
            # Convert timestamps to proper format
            event['event_time'] = self.parse_timestamp(event['event_time'])
            event['detected_time'] = self.parse_timestamp(event['detected_time'])
            
            yield event
            
        except Exception as e:
            logging.error(f"Error processing event: {str(e)}")
            # Don't fail the pipeline, just log the error
            
    def geocode_location(self, lat, lng):
        """Get address from coordinates using Google Geocoding API"""
        try:
            url = "https://maps.googleapis.com/maps/api/geocode/json"
            params = {
                'latlng': f"{lat},{lng}",
                'key': self.geocoding_api_key
            }
            
            response = requests.get(url, params=params, timeout=10)
            response.raise_for_status()
            
            data = response.json()
            if data.get('results'):
                return data['results'][0]['formatted_address']
            return None
            
        except Exception as e:
            logging.warning(f"Geocoding failed: {str(e)}")
            return None
            
    def get_demographics(self, lat, lng):
        """Get demographics data for the location"""
        try:
            # Simple lookup based on proximity
            query = f"""
            SELECT 
                population_density,
                hospitals_count,
                schools_count
            FROM `{self.project_id}.{self.dataset_id}.demographics`
            WHERE ABS(latitude - {lat}) < 0.1 
            AND ABS(longitude - {lng}) < 0.1
            ORDER BY ABS(latitude - {lat}) + ABS(longitude - {lng})
            LIMIT 1
            """
            
            query_job = self.bq_client.query(query)
            results = query_job.result()
            
            for row in results:
                return {
                    'population_density': row.population_density,
                    'hospitals_count': row.hospitals_count,
                    'schools_count': row.schools_count
                }
                
            return {'population_density': None, 'hospitals_count': 0, 'schools_count': 0}
            
        except Exception as e:
            logging.warning(f"Demographics lookup failed: {str(e)}")
            return {'population_density': None, 'hospitals_count': 0, 'schools_count': 0}
            
    def parse_timestamp(self, timestamp_str):
        """Parse timestamp string to proper format"""
        try:
            if isinstance(timestamp_str, str):
                dt = datetime.fromisoformat(timestamp_str.replace('Z', '+00:00'))
                return dt.strftime('%Y-%m-%d %H:%M:%S UTC')
            return timestamp_str
        except:
            return datetime.now(timezone.utc).strftime('%Y-%m-%d %H:%M:%S UTC')

class ImpactScoreCalculator(beam.DoFn):
    """Calculate impact score using ML model"""
    
    def __init__(self, vertex_ai_endpoint):
        self.vertex_ai_endpoint = vertex_ai_endpoint
        
    def setup(self):
        # Initialize Vertex AI client
        from google.cloud import aiplatform
        aiplatform.init(project=os.getenv('GOOGLE_CLOUD_PROJECT'))
        self.endpoint = aiplatform.Endpoint(self.vertex_ai_endpoint)
        
    def process(self, element):
        try:
            # Prepare features for ML model
            features = self.prepare_features(element)
            
            # Get prediction from Vertex AI
            prediction = self.endpoint.predict([features])
            impact_score = prediction.predictions[0][0] if prediction.predictions else 0.5
            
            element['impact_score'] = float(impact_score)
            yield element
            
        except Exception as e:
            logging.error(f"ML prediction failed: {str(e)}")
            element['impact_score'] = 0.5  # Default score
            yield element
            
    def prepare_features(self, event):
        """Prepare features for ML model"""
        return [
            event.get('magnitude', 0) or 0,
            event.get('population_density', 0) or 0,
            1 if event.get('severity') == 'critical' else 0,
            1 if event.get('severity') == 'high' else 0,
            1 if event.get('severity') == 'medium' else 0,
            1 if event.get('event_type') == 'earthquake' else 0,
            1 if event.get('event_type') == 'wildfire' else 0,
            1 if event.get('event_type') == 'volcano' else 0
        ]

def run_pipeline():
    """Main pipeline function"""

    # List of required environment variables
    required_env_vars = [
        'GOOGLE_CLOUD_PROJECT',
        'GOOGLE_CLOUD_REGION',
        'DATAFLOW_TEMP_LOCATION',
        'DATAFLOW_STAGING_LOCATION',
        'DATAFLOW_SERVICE_ACCOUNT',
        'DATAFLOW_JOB_NAME',
        'PUBSUB_TOPIC',
        'GOOGLE_GEOCODING_API_KEY',
        'BIGQUERY_DATASET',
        'BIGQUERY_TABLE_EVENTS'
    ]
    missing_vars = [var for var in required_env_vars if not os.getenv(var)]
    if missing_vars:
        raise EnvironmentError(f"Missing required environment variables: {', '.join(missing_vars)}")

    # Pipeline options
    options = PipelineOptions([
        '--project=' + os.getenv('GOOGLE_CLOUD_PROJECT'),
        '--region=' + os.getenv('GOOGLE_CLOUD_REGION'),
        '--temp_location=' + os.getenv('DATAFLOW_TEMP_LOCATION'),
        '--staging_location=' + os.getenv('DATAFLOW_STAGING_LOCATION'),
        '--service_account_email=' + os.getenv('DATAFLOW_SERVICE_ACCOUNT'),
        '--runner=DataflowRunner',
        '--job_name=' + os.getenv('DATAFLOW_JOB_NAME'),
        '--streaming'
    ])
    
    with beam.Pipeline(options=options) as pipeline:
        
        # Read from Pub/Sub
        events = (
            pipeline 
            | 'Read from PubSub' >> ReadFromPubSub(
                topic=f"projects/{os.getenv('GOOGLE_CLOUD_PROJECT')}/topics/{os.getenv('PUBSUB_TOPIC')}"
            )
        )
        
        # Process and enrich events
        processed_events = (
            events
            | 'Process Events' >> beam.ParDo(DisasterEventProcessor(
                geocoding_api_key=os.getenv('GOOGLE_GEOCODING_API_KEY'),
                project_id=os.getenv('GOOGLE_CLOUD_PROJECT'),
                dataset_id=os.getenv('BIGQUERY_DATASET')
            ))
        )
        
        # Calculate impact scores (if ML endpoint is available)
        if os.getenv('VERTEX_AI_ENDPOINT_NAME'):
            scored_events = (
                processed_events
                | 'Calculate Impact Score' >> beam.ParDo(ImpactScoreCalculator(
                    vertex_ai_endpoint=os.getenv('VERTEX_AI_ENDPOINT_NAME')
                ))
            )
        else:
            scored_events = processed_events
        
        # Write to BigQuery
        (
            scored_events
            | 'Write to BigQuery' >> WriteToBigQuery(
                table=f"{os.getenv('GOOGLE_CLOUD_PROJECT')}.{os.getenv('BIGQUERY_DATASET')}.{os.getenv('BIGQUERY_TABLE_EVENTS')}",
                write_disposition=beam.io.BigQueryDisposition.WRITE_APPEND,
                create_disposition=beam.io.BigQueryDisposition.CREATE_NEVER
            )
        )

if __name__ == '__main__':
    run_pipeline() 