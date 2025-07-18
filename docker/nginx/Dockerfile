# Use the official lightweight NGINX image
FROM nginx:alpine

# Install AWS CLI and envsubst
RUN apk update && \
    apk add --no-cache python3 py3-pip gettext && \
    pip install --break-system-packages awscli && \
    rm -rf /var/cache/apk/*

# Expose the default HTTP port
EXPOSE 80

# Default CMD — ECS overrides, but works for local testing
CMD ["sh", "-c", "\
  echo 'Downloading NGINX configs from S3 bucket with prefix...'; \
  aws s3 cp s3://${NGINX_CONFIG_BUCKET_VAR}/${NGINX_CONFIG_PREFIX}/nginx.template /etc/nginx/nginx.template && \
  aws s3 cp s3://${NGINX_CONFIG_BUCKET_VAR}/${NGINX_CONFIG_PREFIX}/proxy-headers.conf /etc/nginx/proxy-headers.conf && \
  echo 'Substituting environment variables into nginx.conf'; \
  envsubst '${OL_VECTOR_HOST} ${OL_VECTOR_PORT}' < /etc/nginx/nginx.template > /etc/nginx/nginx.conf && \
  echo 'Starting NGINX'; \
  nginx -g 'daemon off;'"]
