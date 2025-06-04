#!/bin/bash
set -e

# Symlink required Grafana directories to the mounted EFS path

mkdir -p /mnt/grafana_efs/{lib,grafana,provisioning,plugins,etc}

ln -snf /mnt/grafana_efs/lib/grafana /var/lib/grafana
ln -snf /mnt/grafana_efs/etc/provisioning /etc/grafana/provisioning
ln -snf /mnt/grafana_efs/etc/grafana.ini /etc/grafana/grafana.ini
ln -snf /mnt/grafana_efs/lib/plugins /var/lib/grafana/plugins

# Execute the original container command
exec "$@"
