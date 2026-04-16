#!/bin/bash
set -eou pipefail

# Enable linger so the rootless user services can be started without the user being logged in
loginctl enable-linger

# Create a secret to be piped into the container as TUNNEL_TOKEN.
# See also: containers/cloudflared.container
secret_name=cloudflared_tunnel_token
read -rs -p "Enter value for $secret_name: " token; echo
printf '%s' "$token" | podman secret create $secret_name -

# Copy container files to ~/.config/containers/systemd
# See also https://docs.podman.io/en/latest/markdown/podman-systemd.unit.5.html#podman-rootless-unit-search-path
mkdir -p ~/.config/containers/systemd/homelab/cloudflared
cp -a containers/. ~/.config/containers/systemd/homelab/cloudflared/

# Reload unit files and rebuild dependency trees
systemctl --user daemon-reload

# Start the services now
systemctl --user start cloudflared

