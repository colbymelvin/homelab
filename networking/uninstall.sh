#!/bin/bash
set -eou pipefail

# Remove the container files from ~/.config/containers/systemd
rm -rf ~/.config/containers/systemd/homelab/networking/

# Reload unit files and rebuild dependency trees 
systemctl --user daemon-reload

