from airflow import DAG
from pendulum import timezone
from datetime import datetime,timedelta
from api.video_statistics import get_playlist_id,get_video_ids,extract_video_data,save_to_json

# Define the local timezone
local_tz = timezone('Asia/Kolkata')

# Default args
default_args = {
    "owner": "BuildItPratik",
    "depends_on_past": False,
    "email_on_failure": False,
    "email_on_retry": False,
    "email": "data@engineers.com",
    # "retry_delay": timedelta(minutes=5),
    "retries": 1,
    "max_active_runs": 1,
    "dagrun_timeout": timedelta(hours=1),
    "start_date": datetime(2025, 1, 1, tzinfo=local_tz),
    # "end_date": datetime(2030, 12, 31, tzinfo=local_tz),
}

with DAG(
    dag_id="produce_json",
    default_args=default_args,
    description="DAG to produce JSON file with raw data",
    schedule="0 14 * * *",   # Every day at 14:00 (2 PM)
    catchup=False,
) as dag:
    
    playlist_id = get_playlist_id()
    video_ids = get_video_ids(playlist_id)
    extract_data = extract_video_data(video_ids)
    save_to_json_task = save_to_json(extract_data)

    playlist_id >> video_ids >> extract_data >> save_to_json_task
