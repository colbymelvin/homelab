#!/bin/bash
set -eou pipefail

# Stop the services now
systemctl --user stop grafana
systemctl --user stop node-exporter
systemctl --user stop prometheus

# Remove the container files from ~/.config/containers/systemd
rm -rf ~/.config/containers/systemd/homelab/monitoring/

# Remove the Home Assistant token secret file
rm -f prometheus/secrets/home_assistant_token

# Reload unit files and rebuild dependency trees
systemctl --user daemon-reload

