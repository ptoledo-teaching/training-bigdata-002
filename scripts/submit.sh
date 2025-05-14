#!/bin/bash

# Export AWS credentials
source ~/scripts/credentials.sh

# Validate required AWS credentials
if [[ -z "$AWS_ACCESS_KEY_ID" || -z "$AWS_SECRET_ACCESS_KEY" ]]; then
  echo "Error: AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY must be set"
  exit 1
fi

# Common configuration
COMMON_CONF="\
  --conf spark.hadoop.fs.s3a.access.key=$AWS_ACCESS_KEY_ID \
  --conf spark.hadoop.fs.s3a.secret.key=$AWS_SECRET_ACCESS_KEY \
  --conf spark.hadoop.fs.s3a.endpoint=s3.amazonaws.com \
  --conf spark.executorEnv.AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID \
  --conf spark.executorEnv.AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY \
  --packages org.apache.hadoop:hadoop-aws:3.3.4 \
  --master spark://$(hostname):7077"

# Conditional credentials
if [[ -n "$AWS_SESSION_TOKEN" ]]; then
  echo "Using temporary AWS credentials"
  spark-submit \
    $COMMON_CONF \
    --conf spark.hadoop.fs.s3a.session.token=$AWS_SESSION_TOKEN \
    --conf spark.hadoop.fs.s3a.aws.credentials.provider=org.apache.hadoop.fs.s3a.TemporaryAWSCredentialsProvider \
    --conf spark.executorEnv.AWS_SESSION_TOKEN=$AWS_SESSION_TOKEN \
    "$1"
else
  echo "Using long-term AWS credentials"
  spark-submit \
    $COMMON_CONF \
    --conf spark.hadoop.fs.s3a.aws.credentials.provider=org.apache.hadoop.fs.s3a.SimpleAWSCredentialsProvider \
    "$1"
fi
