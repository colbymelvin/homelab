#!/bin/bash
set -eou pipefail

# Stop the services now
systemctl --user stop cloudflared

# Remove the container files from ~/.config/containers/systemd
rm -rf ~/.config/containers/systemd/homelab/cloudflared/

# Reload unit files and rebuild dependency trees 
systemctl --user daemon-reload

