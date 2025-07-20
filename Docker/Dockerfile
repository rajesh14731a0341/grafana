FROM grafana/grafana-enterprise:latest

# Install ClickHouse and Redis plugins
RUN grafana-cli plugins install vertamedia-clickhouse-datasource && \
    grafana-cli plugins install redis-datasource

# Switch to root to install packages and fix permissions
USER root

# Install curl, unzip, awscli, jq (Alpine packages)
RUN apk update && apk add --no-cache \
    curl \
    unzip \
    jq \
    aws-cli

# Create provisioning datasources directory and set ownership by numeric UID:GID
RUN mkdir -p /etc/grafana/provisioning/datasources && \
    chown -R 472:472 /etc/grafana/provisioning/datasources

# Copy provisioning script and make executable
COPY entrypoint.sh /etc/grafana/provision.sh
RUN chmod +x /etc/grafana/provision.sh

# Revert to grafana user
USER grafana

# Override entrypoint to provisioning script
ENTRYPOINT ["/etc/grafana/provision.sh"]
