import streamlit as st
import pandas as pd
import plotly.express as px
import plotly.graph_objects as go
from google.cloud import bigquery
import os
from datetime import datetime, timedelta
import json

# Page configuration
st.set_page_config(
    page_title="Disaster Monitor",
    page_icon="🌍",
    layout="wide",
    initial_sidebar_state="expanded"
)

# Initialize BigQuery client
@st.cache_resource
def get_bq_client():
    return bigquery.Client(project=os.getenv('GOOGLE_CLOUD_PROJECT'))

def load_disaster_data(hours=24):
    """Load disaster events from BigQuery"""
    client = get_bq_client()
    
    query = f"""
    SELECT 
        event_id,
        event_type,
        title,
        description,
        latitude,
        longitude,
        address,
        magnitude,
        severity,
        event_time,
        detected_time,
        source,
        population_density,
        impact_score
    FROM `{os.getenv('GOOGLE_CLOUD_PROJECT')}.{os.getenv('BIGQUERY_DATASET')}.{os.getenv('BIGQUERY_TABLE_EVENTS')}`
    WHERE detected_time >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL {hours} HOUR)
    ORDER BY detected_time DESC
    """
    
    try:
        df = client.query(query).to_dataframe()
        return df
    except Exception as e:
        st.error(f"Error loading data: {e}")
        return pd.DataFrame()

def create_map(df):
    """Create an interactive map of disaster events"""
    if df.empty:
        return None
    
    fig = px.scatter_mapbox(
        df,
        lat='latitude',
        lon='longitude',
        color='event_type',
        size='impact_score',
        hover_name='title',
        hover_data=['severity', 'magnitude', 'address', 'impact_score'],
        zoom=2,
        title="Real-time Disaster Events"
    )
    
    fig.update_layout(
        mapbox_style="open-street-map",
        height=600,
        margin={"r":0,"t":30,"l":0,"b":0}
    )
    
    return fig

def create_timeline(df):
    """Create timeline of events"""
    if df.empty:
        return None
    
    df_timeline = df.copy()
    df_timeline['event_time'] = pd.to_datetime(df_timeline['event_time'])
    
    fig = px.scatter(
        df_timeline,
        x='event_time',
        y='impact_score',
        color='event_type',
        size='magnitude',
        hover_name='title',
        title="Event Timeline"
    )
    
    fig.update_layout(height=400)
    return fig

def create_summary_stats(df):
    """Create summary statistics"""
    if df.empty:
        return {}
    
    stats = {
        'total_events': len(df),
        'event_types': df['event_type'].value_counts().to_dict(),
        'severity_distribution': df['severity'].value_counts().to_dict(),
        'avg_impact_score': df['impact_score'].mean(),
        'max_impact_score': df['impact_score'].max(),
        'recent_events': len(df[df['detected_time'] >= datetime.now() - timedelta(hours=1)])
    }
    
    return stats

def main():
    st.title("🌍 Real-Time Disaster Monitor")
    st.markdown("Live monitoring of natural disasters and their impact assessment")
    
    # Sidebar filters
    st.sidebar.header("Filters")
    
    hours = st.sidebar.slider(
        "Time Range (hours)",
        min_value=1,
        max_value=168,  # 1 week
        value=24,
        step=1
    )
    
    event_types = st.sidebar.multiselect(
        "Event Types",
        ["earthquake", "wildfire", "volcano", "severe-storms"],
        default=["earthquake", "wildfire", "volcano", "severe-storms"]
    )
    
    severity_filter = st.sidebar.multiselect(
        "Severity Levels",
        ["low", "medium", "high", "critical"],
        default=["low", "medium", "high", "critical"]
    )
    
    # Load data
    with st.spinner("Loading disaster data..."):
        df = load_disaster_data(hours)
    
    if df.empty:
        st.warning("No disaster events found in the selected time range.")
        return
    
    # Apply filters
    if event_types:
        df = df[df['event_type'].isin(event_types)]
    
    if severity_filter:
        df = df[df['severity'].isin(severity_filter)]
    
    # Summary statistics
    stats = create_summary_stats(df)
    
    # Display summary metrics
    col1, col2, col3, col4 = st.columns(4)
    
    with col1:
        st.metric("Total Events", stats['total_events'])
    
    with col2:
        st.metric("Recent Events (1h)", stats['recent_events'])
    
    with col3:
        st.metric("Avg Impact Score", f"{stats['avg_impact_score']:.2f}")
    
    with col4:
        st.metric("Max Impact Score", f"{stats['max_impact_score']:.2f}")
    
    # Main content
    tab1, tab2, tab3 = st.tabs(["Map View", "Timeline", "Data Table"])
    
    with tab1:
        st.subheader("Geographic Distribution")
        map_fig = create_map(df)
        if map_fig:
            st.plotly_chart(map_fig, use_container_width=True)
        else:
            st.info("No data to display on map")
    
    with tab2:
        st.subheader("Event Timeline")
        timeline_fig = create_timeline(df)
        if timeline_fig:
            st.plotly_chart(timeline_fig, use_container_width=True)
        else:
            st.info("No data to display in timeline")
    
    with tab3:
        st.subheader("Event Details")
        
        # Add search functionality
        search = st.text_input("Search events by title or description")
        if search:
            df_filtered = df[
                df['title'].str.contains(search, case=False, na=False) |
                df['description'].str.contains(search, case=False, na=False)
            ]
        else:
            df_filtered = df
        
        # Display table
        if not df_filtered.empty:
            display_df = df_filtered[[
                'event_type', 'title', 'severity', 'magnitude', 
                'impact_score', 'address', 'event_time', 'source'
            ]].copy()
            
            display_df['event_time'] = pd.to_datetime(display_df['event_time']).dt.strftime('%Y-%m-%d %H:%M')
            display_df['impact_score'] = display_df['impact_score'].round(3)
            
            st.dataframe(
                display_df,
                use_container_width=True,
                hide_index=True
            )
        else:
            st.info("No events match the search criteria")
    
    # Event type distribution
    st.subheader("Event Distribution")
    col1, col2 = st.columns(2)
    
    with col1:
        if stats['event_types']:
            event_fig = px.pie(
                values=list(stats['event_types'].values()),
                names=list(stats['event_types'].keys()),
                title="Events by Type"
            )
            st.plotly_chart(event_fig, use_container_width=True)
    
    with col2:
        if stats['severity_distribution']:
            severity_fig = px.bar(
                x=list(stats['severity_distribution'].keys()),
                y=list(stats['severity_distribution'].values()),
                title="Events by Severity"
            )
            st.plotly_chart(severity_fig, use_container_width=True)
    
    # Footer
    st.markdown("---")
    st.markdown(
        "Data sources: USGS (Earthquakes), NASA EONET (Natural Events) | "
        "Last updated: " + datetime.now().strftime("%Y-%m-%d %H:%M:%S UTC")
    )

if __name__ == "__main__":
    main() 