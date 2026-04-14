#!/bin/bash
set -eou pipefail

# Enable linger so the rootless user services can be started without the user being logged in
loginctl enable-linger

# Copy container files to ~/.config/containers/systemd
# See also https://docs.podman.io/en/latest/markdown/podman-systemd.unit.5.html#podman-rootless-unit-search-path
mkdir -p ~/.config/containers/systemd/homelab/cloudflared
cp -a containers/. ~/.config/containers/systemd/homelab/cloudflared/

# Reload unit files and rebuild dependency trees 
systemctl --user daemon-reload

##########################
# Handle secret generation
##########################

trap 'echo -e "\nAborted."; exit 1' INT
read -rs -p "Enter token (Ctrl+C to cancel): " TOKEN; echo
printf '%s' "$TOKEN" | podman secret create cloudflared_tunnel_token -

# Start the services now
systemctl --user start cloudflared

