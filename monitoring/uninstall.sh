#!/bin/bash
set -eou pipefail

# Stop the services now
systemctl --user stop grafana
systemctl --user stop node-exporter
systemctl --user stop prometheus

# Remove the container files from ~/.config/containers/systemd
rm -rf ~/.config/containers/systemd/homelab/monitoring/

# Reload unit files and rebuild dependency trees 
systemctl --user daemon-reload

