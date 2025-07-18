# Use lightweight official NGINX image
FROM nginx:alpine

# Install AWS CLI and envsubst
RUN apk update && \
    apk add --no-cache python3 py3-pip gettext && \
    pip install --break-system-packages awscli && \
    rm -rf /var/cache/apk/*

# Copy entrypoint script into container
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Expose HTTP port
EXPOSE 80

# Always use the entrypoint script
ENTRYPOINT ["/entrypoint.sh"]
