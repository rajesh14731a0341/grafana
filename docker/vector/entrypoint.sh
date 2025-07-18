#!/bin/sh
set -e

echo "Downloading Vector config from S3..."
aws s3 cp s3://${VECTOR_CONFIG_BUCKET}/${VECTOR_CONFIG_PREFIX}/vector.yaml /etc/vector/vector.yaml

echo "Starting Vector..."
exec vector --config /etc/vector/vector.yaml
