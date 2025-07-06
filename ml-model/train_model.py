import pandas as pd
import numpy as np
from sklearn.ensemble import RandomForestRegressor
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
from sklearn.metrics import mean_squared_error, r2_score
import joblib
import os
from google.cloud import bigquery
from google.cloud import aiplatform
import json

def load_training_data(project_id, dataset_id):
    """Load training data from BigQuery"""
    client = bigquery.Client(project=project_id)
    
    query = f"""
    SELECT 
        magnitude,
        population_density,
        CASE 
            WHEN severity = 'critical' THEN 1 ELSE 0 
        END as severity_critical,
        CASE 
            WHEN severity = 'high' THEN 1 ELSE 0 
        END as severity_high,
        CASE 
            WHEN severity = 'medium' THEN 1 ELSE 0 
        END as severity_medium,
        CASE 
            WHEN event_type = 'earthquake' THEN 1 ELSE 0 
        END as event_earthquake,
        CASE 
            WHEN event_type = 'wildfire' THEN 1 ELSE 0 
        END as event_wildfire,
        CASE 
            WHEN event_type = 'volcano' THEN 1 ELSE 0 
        END as event_volcano,
        COALESCE(impact_score, 0.5) as target
    FROM `{project_id}.{dataset_id}.disaster_events`
    WHERE impact_score IS NOT NULL
    AND magnitude IS NOT NULL
    AND population_density IS NOT NULL
    """
    
    df = client.query(query).to_dataframe()
    return df

def create_synthetic_data():
    """Create synthetic training data if no real data exists"""
    np.random.seed(42)
    n_samples = 1000
    
    data = {
        'magnitude': np.random.uniform(0, 10, n_samples),
        'population_density': np.random.uniform(0, 10000, n_samples),
        'severity_critical': np.random.choice([0, 1], n_samples, p=[0.9, 0.1]),
        'severity_high': np.random.choice([0, 1], n_samples, p=[0.7, 0.3]),
        'severity_medium': np.random.choice([0, 1], n_samples, p=[0.5, 0.5]),
        'event_earthquake': np.random.choice([0, 1], n_samples, p=[0.6, 0.4]),
        'event_wildfire': np.random.choice([0, 1], n_samples, p=[0.7, 0.3]),
        'event_volcano': np.random.choice([0, 1], n_samples, p=[0.9, 0.1])
    }
    
    # Create target variable based on features
    target = (
        data['magnitude'] * 0.1 +
        data['population_density'] * 0.00001 +
        data['severity_critical'] * 0.3 +
        data['severity_high'] * 0.2 +
        data['severity_medium'] * 0.1 +
        data['event_volcano'] * 0.2 +
        np.random.normal(0, 0.1, n_samples)
    )
    
    data['target'] = np.clip(target, 0, 1)
    
    return pd.DataFrame(data)

def train_model(X_train, y_train, X_val, y_val):
    """Train the Random Forest model"""
    model = RandomForestRegressor(
        n_estimators=100,
        max_depth=10,
        random_state=42,
        n_jobs=-1
    )
    
    model.fit(X_train, y_train)
    
    # Evaluate model
    y_pred = model.predict(X_val)
    mse = mean_squared_error(y_val, y_pred)
    r2 = r2_score(y_val, y_pred)
    
    print(f"Validation MSE: {mse:.4f}")
    print(f"Validation R²: {r2:.4f}")
    
    return model

def save_model(model, scaler, model_dir):
    """Save the trained model and scaler"""
    os.makedirs(model_dir, exist_ok=True)
    
    # Save model
    joblib.dump(model, os.path.join(model_dir, 'model.joblib'))
    
    # Save scaler
    joblib.dump(scaler, os.path.join(model_dir, 'scaler.joblib'))
    
    # Save feature names
    feature_names = [
        'magnitude', 'population_density', 'severity_critical',
        'severity_high', 'severity_medium', 'event_earthquake',
        'event_wildfire', 'event_volcano'
    ]
    
    with open(os.path.join(model_dir, 'feature_names.json'), 'w') as f:
        json.dump(feature_names, f)
    
    print(f"Model saved to {model_dir}")

def deploy_to_vertex_ai(model_dir, project_id, region, model_name):
    """Deploy model to Vertex AI"""
    aiplatform.init(project=project_id, location=region)
    
    # Create model
    model = aiplatform.Model.upload(
        display_name=model_name,
        artifact_uri=model_dir,
        serving_container_image_uri="us-docker.pkg.dev/cloud-aiplatform/prediction/sklearn-cpu.1-3:latest"
    )
    
    # Create endpoint
    endpoint = model.deploy(
        machine_type="n1-standard-4",
        accelerator_type=None,
        accelerator_count=None
    )
    
    print(f"Model deployed to endpoint: {endpoint.resource_name}")
    return endpoint.resource_name

def main():
    """Main training function"""
    project_id = os.getenv('GOOGLE_CLOUD_PROJECT')
    dataset_id = os.getenv('BIGQUERY_DATASET')
    region = os.getenv('GOOGLE_CLOUD_REGION')
    model_name = os.getenv('VERTEX_AI_MODEL_NAME')
    
    print("Loading training data...")
    
    try:
        # Try to load real data
        df = load_training_data(project_id, dataset_id)
        if len(df) < 100:
            print("Not enough real data, using synthetic data...")
            df = create_synthetic_data()
    except Exception as e:
        print(f"Error loading real data: {e}")
        print("Using synthetic data...")
        df = create_synthetic_data()
    
    print(f"Training data shape: {df.shape}")
    
    # Prepare features and target
    feature_cols = [col for col in df.columns if col != 'target']
    X = df[feature_cols]
    y = df['target']
    
    # Split data
    X_train, X_temp, y_train, y_temp = train_test_split(X, y, test_size=0.3, random_state=42)
    X_val, X_test, y_val, y_test = train_test_split(X_temp, y_temp, test_size=0.5, random_state=42)
    
    # Scale features
    scaler = StandardScaler()
    X_train_scaled = scaler.fit_transform(X_train)
    X_val_scaled = scaler.transform(X_val)
    X_test_scaled = scaler.transform(X_test)
    
    # Train model
    print("Training model...")
    model = train_model(X_train_scaled, y_train, X_val_scaled, y_val)
    
    # Test model
    y_test_pred = model.predict(X_test_scaled)
    test_mse = mean_squared_error(y_test, y_test_pred)
    test_r2 = r2_score(y_test, y_test_pred)
    
    print(f"Test MSE: {test_mse:.4f}")
    print(f"Test R²: {test_r2:.4f}")
    
    # Save model
    model_dir = "./model"
    save_model(model, scaler, model_dir)
    
    # Deploy to Vertex AI
    if os.getenv('DEPLOY_TO_VERTEX_AI', 'false').lower() == 'true':
        print("Deploying to Vertex AI...")
        endpoint_name = deploy_to_vertex_ai(model_dir, project_id, region, model_name)
        
        # Save endpoint name
        with open('endpoint_name.txt', 'w') as f:
            f.write(endpoint_name)
        
        print(f"Endpoint name saved to endpoint_name.txt")

if __name__ == "__main__":
    main() 