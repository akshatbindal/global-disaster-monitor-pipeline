import functions_framework
import requests
import json
import uuid
from datetime import datetime, timezone
from google.cloud import pubsub_v1
import os

# Initialize Pub/Sub client
publisher = pubsub_v1.PublisherClient()
topic_path = publisher.topic_path(os.getenv('GOOGLE_CLOUD_PROJECT'), os.getenv('PUBSUB_TOPIC'))

@functions_framework.cloud_event
def ingest_disaster_data(cloud_event):
    """Cloud Function to ingest disaster data from USGS and NASA APIs"""
    
    try:
        # Fetch earthquake data from USGS
        earthquake_data = fetch_usgs_earthquakes()
        
        # Fetch natural events from NASA EONET
        nasa_data = fetch_nasa_eonet()
        
        # Combine and publish all data
        all_events = earthquake_data + nasa_data
        
        for event in all_events:
            publish_event(event)
            
        print(f"Successfully processed {len(all_events)} disaster events")
        
    except Exception as e:
        print(f"Error in disaster data ingestion: {str(e)}")
        raise

def fetch_usgs_earthquakes():
    """Fetch recent earthquake data from USGS API"""
    try:
        url = f"{os.getenv('USGS_API_BASE_URL')}/summary/all_hour.geojson"
        response = requests.get(url, timeout=30)
        response.raise_for_status()
        
        data = response.json()
        events = []
        
        for feature in data.get('features', []):
            properties = feature.get('properties', {})
            geometry = feature.get('geometry', {})
            
            if geometry.get('type') == 'Point' and geometry.get('coordinates'):
                coords = geometry['coordinates']
                
                event = {
                    'event_id': f"usgs_{properties.get('id', str(uuid.uuid4()))}",
                    'event_type': 'earthquake',
                    'title': properties.get('title', 'Earthquake'),
                    'description': properties.get('title', ''),
                    'latitude': coords[1],
                    'longitude': coords[0],
                    'magnitude': properties.get('mag'),
                    'severity': get_earthquake_severity(properties.get('mag')),
                    'event_time': datetime.fromtimestamp(properties.get('time', 0) / 1000, tz=timezone.utc).isoformat(),
                    'detected_time': datetime.now(timezone.utc).isoformat(),
                    'source': 'USGS',
                    'raw_data': json.dumps(properties)
                }
                events.append(event)
        
        return events
        
    except Exception as e:
        print(f"Error fetching USGS data: {str(e)}")
        return []

def fetch_nasa_eonet():
    """Fetch natural events from NASA EONET API"""
    try:
        url = f"{os.getenv('NASA_EONET_API_BASE_URL')}/events"
        params = {
            'limit': 50,
            'days': 1,
            'category': 'severe-storms,volcanoes,wildfires'
        }
        
        response = requests.get(url, params=params, timeout=30)
        response.raise_for_status()
        
        data = response.json()
        events = []
        
        for event in data.get('events', []):
            geometry = event.get('geometry', [])
            
            if geometry and len(geometry) > 0:
                coords = geometry[0].get('coordinates', [])
                
                if len(coords) >= 2:
                    event_data = {
                        'event_id': f"nasa_{event.get('id', str(uuid.uuid4()))}",
                        'event_type': event.get('categories', [{}])[0].get('title', 'natural-event').lower(),
                        'title': event.get('title', 'Natural Event'),
                        'description': event.get('description', ''),
                        'latitude': coords[1],
                        'longitude': coords[0],
                        'severity': get_nasa_severity(event),
                        'event_time': event.get('geometry', [{}])[0].get('date', datetime.now(timezone.utc).isoformat()),
                        'detected_time': datetime.now(timezone.utc).isoformat(),
                        'source': 'NASA',
                        'raw_data': json.dumps(event)
                    }
                    events.append(event_data)
        
        return events
        
    except Exception as e:
        print(f"Error fetching NASA data: {str(e)}")
        return []

def get_earthquake_severity(magnitude):
    """Determine severity based on earthquake magnitude"""
    if magnitude is None:
        return 'unknown'
    elif magnitude >= 8.0:
        return 'critical'
    elif magnitude >= 6.0:
        return 'high'
    elif magnitude >= 4.0:
        return 'medium'
    else:
        return 'low'

def get_nasa_severity(event):
    """Determine severity for NASA events"""
    # Simple heuristic based on event type
    event_type = event.get('categories', [{}])[0].get('title', '').lower()
    
    if 'severe' in event_type:
        return 'high'
    elif 'volcano' in event_type:
        return 'high'
    elif 'wildfire' in event_type:
        return 'medium'
    else:
        return 'low'

def publish_event(event):
    """Publish event to Pub/Sub topic"""
    try:
        message = json.dumps(event).encode('utf-8')
        future = publisher.publish(topic_path, data=message)
        future.result()
        print(f"Published event: {event['event_id']}")
    except Exception as e:
        print(f"Error publishing event {event['event_id']}: {str(e)}") 