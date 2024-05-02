mkdir -p ~/data
aws s3 cp s3://utfsm-datasets-inf356/vlt_observations/vlt_observations_000.csv ~/data/
hdfs dfs -mkdir -p /data
hdfs dfs -put ~/data/vlt_observations_000.csv /data/