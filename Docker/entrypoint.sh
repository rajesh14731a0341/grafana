#!/bin/bash
set -e

# Validate required environment variables
: "${GF_SECURITY_ADMIN_USER:?Missing GF_SECURITY_ADMIN_USER}"
: "${GF_SECURITY_ADMIN_PASSWORD:?Missing GF_SECURITY_ADMIN_PASSWORD}"
: "${GRAFANA_DATASOURCE_BUCKET:?Missing GRAFANA_DATASOURCE_BUCKET}"
: "${GRAFANA_DATASOURCE_PREFIX:?Missing GRAFANA_DATASOURCE_PREFIX}"

echo "[Provisioning] Starting Grafana..."
/run.sh &

GRAFANA_PID=$!

# Wait for Grafana to become healthy
echo "[Provisioning] Waiting for Grafana to be healthy..."
for i in {1..30}; do
  STATUS=$(curl -s -u "${GF_SECURITY_ADMIN_USER}:${GF_SECURITY_ADMIN_PASSWORD}" \
    http://localhost:3000/api/health | jq -r '.status')

  if [ "$STATUS" == "ok" ]; then
    echo "[Provisioning] Grafana is healthy."
    break
  fi

  echo "[Provisioning] Waiting... ($i/30)"
  sleep 5
done

# Download datasource JSONs from S3 to Grafana provisioning directory
echo "[Provisioning] Downloading datasource files from S3..."
mkdir -p /etc/grafana/provisioning/datasources

aws s3 cp "s3://${GRAFANA_DATASOURCE_BUCKET}/${GRAFANA_DATASOURCE_PREFIX}/" \
  /etc/grafana/provisioning/datasources/ --recursive

# Provision each datasource via API
for f in /etc/grafana/provisioning/datasources/*.json; do
  echo "[Provisioning] Posting $f"

  HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" \
    -u "${GF_SECURITY_ADMIN_USER}:${GF_SECURITY_ADMIN_PASSWORD}" \
    -X POST http://localhost:3000/api/datasources \
    -H "Content-Type: application/json" \
    -d @"$f")

  if [ "$HTTP_CODE" -eq 200 ] || [ "$HTTP_CODE" -eq 409 ]; then
    echo "[Provisioning] Successfully provisioned $(basename "$f")"
  else
    echo "[Provisioning] Failed to provision $(basename "$f") (HTTP $HTTP_CODE)"
  fi
done

wait $GRAFANA_PID
