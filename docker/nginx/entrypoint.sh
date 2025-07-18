#!/bin/sh
set -e

echo "Downloading NGINX configs from s3://${NGINX_CONFIG_BUCKET_VAR}/${NGINX_CONFIG_PREFIX}/"

aws s3 cp "s3://${NGINX_CONFIG_BUCKET_VAR}/${NGINX_CONFIG_PREFIX}/nginx.template" /etc/nginx/nginx.template
aws s3 cp "s3://${NGINX_CONFIG_BUCKET_VAR}/${NGINX_CONFIG_PREFIX}/proxy-headers.conf" /etc/nginx/proxy-headers.conf

echo "Generating nginx.conf using envsubst"
envsubst '${OL_VECTOR_HOST} ${OL_VECTOR_PORT}' < /etc/nginx/nginx.template > /etc/nginx/nginx.conf

echo "Starting NGINX"
exec nginx -g 'daemon off;'
