FROM grafana/grafana-enterprise:latest

# Install ClickHouse and Redis plugins
RUN grafana-cli plugins install vertamedia-clickhouse-datasource && \
    grafana-cli plugins install redis-datasource

# Switch to root to install packages
USER root

# Install curl, unzip, awscli, jq (Alpine versions)
RUN apk update && apk add --no-cache \
    curl \
    unzip \
    jq \
    aws-cli

# Copy provisioning script and make it executable
COPY entrypoint.sh /etc/grafana/provision.sh
RUN chmod +x /etc/grafana/provision.sh

# Revert to Grafana user
USER grafana

# Run provisioning script (downloads S3 datasources, then starts Grafana)
#override entrypoint
ENTRYPOINT ["/etc/grafana/provision.sh"]
