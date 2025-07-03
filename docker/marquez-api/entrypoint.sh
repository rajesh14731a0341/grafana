#!/bin/sh

echo "⏳ Waiting for PostgreSQL to be available at $MARQUEZ_POSTGRES_HOST:$MARQUEZ_POSTGRES_PORT..."

for i in $(seq 1 30); do
  nc -z "$MARQUEZ_POSTGRES_HOST" "$MARQUEZ_POSTGRES_PORT" && break
  echo "Attempt $i: DB not ready yet..."
  sleep 5
done

echo "✅ PostgreSQL is up. Interpolating config..."

# Interpolate env vars into a temp config file
envsubst < /usr/src/app/marquez.dev.yml > /tmp/marquez.dev.yml

echo "🔍 Using interpolated JDBC URL:"
grep 'url:' /tmp/marquez.dev.yml

echo "🚀 Starting Marquez..."
exec java -jar /usr/src/app/marquez-api-0.47.0.jar server /tmp/marquez.dev.yml
