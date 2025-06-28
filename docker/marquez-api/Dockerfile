FROM marquezproject/marquez:0.47.0

# Install nc (netcat) and curl
USER root
RUN apk add --no-cache netcat-openbsd curl

# Copy config and entrypoint
COPY marquez.dev.yml /usr/src/app/marquez.dev.yml
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
