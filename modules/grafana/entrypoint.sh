#!/bin/sh

# Create symlinks to EFS volumes inside container paths

ln -snf /mnt/grafana_efs/var_lib_grafana /var/lib/grafana
ln -snf /mnt/grafana_efs/etc_grafana_provisioning /etc/grafana/provisioning
ln -snf /mnt/grafana_efs/etc_grafana_grafana_ini /etc/grafana/grafana.ini
ln -snf /mnt/grafana_efs/var_lib_grafana_plugins /var/lib/grafana/plugins

exec "$@"
