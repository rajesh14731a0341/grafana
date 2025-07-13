FROM grafana/grafana-enterprise:latest

# Install ClickHouse plugin with basic check
RUN grafana-cli plugins install vertamedia-clickhouse-datasource && \
    grafana-cli plugins ls | grep -q vertamedia-clickhouse-datasource
