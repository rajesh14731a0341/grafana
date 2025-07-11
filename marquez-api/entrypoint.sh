#!/bin/sh

echo "⏳ Waiting for PostgreSQL to be available at $MARQUEZ_POSTGRES_HOST:$MARQUEZ_POSTGRES_PORT..."

for i in $(seq 1 30); do
  nc -z "$MARQUEZ_POSTGRES_HOST" "$MARQUEZ_POSTGRES_PORT" && break
  echo "Attempt $i: DB not ready yet..."
  sleep 10
done

echo "✅ PostgreSQL is up. Starting Marquez..."

# Run the Marquez jar directly (use exact jar name present in image)
exec java -jar /usr/src/app/marquez-api-0.47.0.jar server /usr/src/app/marquez.dev.yml
