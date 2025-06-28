#!/bin/sh

echo "⏳ Waiting for PostgreSQL to be available at $MARQUEZ_POSTGRES_HOST:$MARQUEZ_POSTGRES_PORT..."

for i in $(seq 1 30); do
  nc -z "$MARQUEZ_POSTGRES_HOST" "$MARQUEZ_POSTGRES_PORT" && break
  echo "Attempt $i: DB not ready yet..."
  sleep 10
done

echo "✅ PostgreSQL is up. Starting Marquez..."

# Use the official Marquez entrypoint (respects $MARQUEZ_CONFIG)
exec /usr/src/app/docker-entrypoint.sh
