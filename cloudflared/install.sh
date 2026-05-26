#!/bin/bash
set -eou pipefail

# Enable linger so the rootless user services can be started without the user being logged in
loginctl enable-linger

# Write the tunnel token to a file so it persists across restarts.
# See also: containers/cloudflared.container
mkdir -p secrets/
secret_file="secrets/cloudflared_tunnel_token"
file_exists=false
overwrite=false
if [[ -f "$secret_file" ]]; then
    file_exists=true
    read -r -p "$secret_file already exists. Overwrite? [y/N] " confirm; echo
    if [[ "${confirm,,}" == "y" ]]; then
        overwrite=true
    else
        echo "Keeping existing $secret_file"
    fi
fi
if [[ "$file_exists" == false || "$overwrite" == true ]]; then
    read -rs -p "Enter value for $secret_file: " token; echo
    printf 'TUNNEL_TOKEN=%s\n' "$token" > "$secret_file"
    chmod 644 "$secret_file"
fi

# Copy container files to ~/.config/containers/systemd
# See also https://docs.podman.io/en/latest/markdown/podman-systemd.unit.5.html#podman-rootless-unit-search-path
mkdir -p ~/.config/containers/systemd/homelab/cloudflared
cp -a containers/. ~/.config/containers/systemd/homelab/cloudflared/

# Reload unit files and rebuild dependency trees
systemctl --user daemon-reload

# Start the services now
systemctl --user start cloudflared

