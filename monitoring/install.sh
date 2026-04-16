#!/bin/bash
set -eou pipefail

# Enable linger so the rootless user services can be started without the user being logged in
loginctl enable-linger

# Create credentials files for authenticated Prometheus/metrics endpoints if they don't exist
# See also: containers/prometheus.container and prometheus/prometheus.yml
mkdir -p prometheus/secrets/
home_assistant_secret_file="prometheus/secrets/home_assistant_token"
read -rs -p "Enter value for $home_assistant_secret_file: " token; echo
printf '%s\n' "$token" > "$home_assistant_secret_file"
chmod 600 "$home_assistant_secret_file"

# Copy container files to ~/.config/containers/systemd
# See also https://docs.podman.io/en/latest/markdown/podman-systemd.unit.5.html#podman-rootless-unit-search-path
mkdir -p ~/.config/containers/systemd/homelab/monitoring
cp -a containers/. ~/.config/containers/systemd/homelab/monitoring/

# Reload unit files and rebuild dependency trees 
systemctl --user daemon-reload

# Start the services now
systemctl --user start grafana
systemctl --user start node-exporter
systemctl --user start prometheus

