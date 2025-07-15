FROM grafana/grafana-enterprise:latest

# Install ClickHouse plugin
RUN grafana-cli plugins install vertamedia-clickhouse-datasource && \
    grafana-cli plugins ls | grep -q vertamedia-clickhouse-datasource

# Install Redis plugin
RUN grafana-cli plugins install redis-datasource && \
    grafana-cli plugins ls | grep -q redis-datasource
