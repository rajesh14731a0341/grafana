FROM marquezproject/marquez:0.47.0

# Switch to root to install packages
USER root

# Install netcat and curl using apt (Debian-based base image)
RUN apt-get update && apt-get install -y netcat curl && rm -rf /var/lib/apt/lists/*

# Copy custom config and entrypoint script
COPY marquez.dev.yml /usr/src/app/marquez.dev.yml
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

# Make entrypoint executable
RUN chmod +x /usr/local/bin/entrypoint.sh

# Use custom entrypoint
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
