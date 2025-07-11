# Use the official lightweight NGINX image
FROM nginx:alpine

# Install AWS CLI and envsubst
RUN apk update && \
    apk add --no-cache python3 py3-pip gettext && \
    pip install --break-system-packages awscli && \
    rm -rf /var/cache/apk/*

# Expose the default HTTP port
EXPOSE 80

# Default CMD — ECS will override, but good for local testing
CMD ["sh", "-c", "\
  aws s3 cp s3://${NGINX_CONFIG_BUCKET_VAR}/nginx.template /etc/nginx/nginx.template && \
  envsubst < /etc/nginx/nginx.template > /etc/nginx/nginx.conf && \
  nginx -g 'daemon off;'"]
