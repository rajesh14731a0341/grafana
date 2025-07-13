FROM timberio/vector:0.39.0-alpine

# Install bash and AWS CLI
RUN apk add --no-cache bash python3 py3-pip && \
    pip3 install --break-system-packages awscli && \
    mkdir -p /etc/vector

# Copy the startup script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Set working directory
WORKDIR /etc/vector

# Use shell script as entrypoint
ENTRYPOINT ["/entrypoint.sh"]
