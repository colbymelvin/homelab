#!/bin/bash
set -eou pipefail

# Copy container files to ~/.config/containers/systemd
# See also https://docs.podman.io/en/latest/markdown/podman-systemd.unit.5.html#podman-rootless-unit-search-path
mkdir -p ~/.config/containers/systemd/homelab/networking
cp -a containers/. ~/.config/containers/systemd/homelab/networking/

# Reload unit files and rebuild dependency trees
systemctl --user daemon-reload

