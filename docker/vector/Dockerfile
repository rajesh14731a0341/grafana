FROM timberio/vector:0.39.0-alpine

# Install bash and AWS CLI
RUN apk add --no-cache \
      bash \
      python3 \
      py3-pip && \
    pip3 install --break-system-packages awscli && \
    mkdir -p /etc/vector

# Set working directory
WORKDIR /etc/vector

# Default startup script
CMD ["sh", "-c", "\
  aws s3 cp s3://${VECTOR_CONFIG_BUCKET}/vector.yaml /etc/vector/vector.yaml && \
  vector --config /etc/vector/vector.yaml"]
