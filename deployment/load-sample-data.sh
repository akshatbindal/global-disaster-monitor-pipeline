#!/bin/bash

# Load Sample Data Script
# This script loads sample demographics data into BigQuery

set -e

echo "📊 Loading Sample Demographics Data..."

# Load environment variables
if [ -f "../env.example" ]; then
    export $(cat ../env.example | grep -v '^#' | xargs)
fi

# Check if required variables are set
if [ -z "$GOOGLE_CLOUD_PROJECT" ]; then
    echo "❌ Error: GOOGLE_CLOUD_PROJECT not set"
    exit 1
fi

# Create sample data CSV
echo "📝 Creating sample demographics data..."
cat > sample_demographics.csv << EOF
location_id,latitude,longitude,address,population_density,total_population,area_km2,hospitals_count,schools_count,critical_infrastructure,last_updated
loc_001,40.7128,-74.0060,"New York, NY, USA",10833,8336817,778.2,150,1200,"power_plant,airport,subway",2024-01-01 00:00:00 UTC
loc_002,34.0522,-118.2437,"Los Angeles, CA, USA",3200,3979576,1302.0,120,800,"airport,port,highway",2024-01-01 00:00:00 UTC
loc_003,41.8781,-87.6298,"Chicago, IL, USA",4600,2693976,606.1,80,600,"airport,railway,power_plant",2024-01-01 00:00:00 UTC
loc_004,29.7604,-95.3698,"Houston, TX, USA",1400,2320268,1651.0,60,400,"port,airport,refinery",2024-01-01 00:00:00 UTC
loc_005,33.7490,-84.3880,"Atlanta, GA, USA",1600,498044,347.1,40,300,"airport,highway,railway",2024-01-01 00:00:00 UTC
loc_006,39.9526,-75.1652,"Philadelphia, PA, USA",4500,1603797,369.4,70,500,"port,railway,power_plant",2024-01-01 00:00:00 UTC
loc_007,25.7617,-80.1918,"Miami, FL, USA",2800,454279,143.1,50,350,"port,airport,highway",2024-01-01 00:00:00 UTC
loc_008,32.7767,-96.7970,"Dallas, TX, USA",1400,1343573,997.1,45,320,"airport,highway,railway",2024-01-01 00:00:00 UTC
loc_009,37.7749,-122.4194,"San Francisco, CA, USA",7200,873965,121.4,30,250,"port,airport,power_plant",2024-01-01 00:00:00 UTC
loc_010,38.9072,-77.0369,"Washington, DC, USA",4100,689545,177.0,25,200,"government,airport,railway",2024-01-01 00:00:00 UTC
loc_011,35.2271,-80.8431,"Charlotte, NC, USA",1200,885708,771.0,35,280,"airport,highway,power_plant",2024-01-01 00:00:00 UTC
loc_012,42.3601,-71.0589,"Boston, MA, USA",5400,675647,125.4,40,300,"port,airport,railway",2024-01-01 00:00:00 UTC
loc_013,47.6062,-122.3321,"Seattle, WA, USA",3200,744955,232.6,30,250,"port,airport,power_plant",2024-01-01 00:00:00 UTC
loc_014,39.7392,-104.9903,"Denver, CO, USA",1800,727211,401.4,25,200,"airport,railway,highway",2024-01-01 00:00:00 UTC
loc_015,36.1699,-115.1398,"Las Vegas, NV, USA",1700,651319,351.9,20,150,"airport,highway,power_plant",2024-01-01 00:00:00 UTC
EOF

# Load data into BigQuery
echo "📤 Loading data into BigQuery..."
bq load \
    --source_format=CSV \
    --skip_leading_rows=1 \
    --autodetect \
    ${GOOGLE_CLOUD_PROJECT}.${BIGQUERY_DATASET:-disaster_monitor}.${BIGQUERY_TABLE_DEMOGRAPHICS:-demographics} \
    sample_demographics.csv

# Clean up
rm sample_demographics.csv

echo "✅ Sample demographics data loaded successfully!"
echo "📊 Data loaded into: ${GOOGLE_CLOUD_PROJECT}.${BIGQUERY_DATASET:-disaster_monitor}.${BIGQUERY_TABLE_DEMOGRAPHICS:-demographics}" 