#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SYSTEMD_DIR="$HOME/.config/containers/systemd/homelab"
NETWORKING="networking"

prompt_secret() {
  local service="$1"
  local secrets_file="$ROOT_DIR/$service/secrets"
  [[ -f "$secrets_file" ]] || return

  # Take the first non-comment, non-blank line as the spec
  local path env_var
  read -r path env_var < <(sed -E 's/#.*$//' "$secrets_file" | awk 'NF{print;exit}')
  [[ -z "${path:-}" ]] && return

  local secret_file="$ROOT_DIR/$service/$path"
  mkdir -p "$(dirname "$secret_file")"

  if [[ -f "$secret_file" ]]; then
    read -r -p "$secret_file already exists. Overwrite? [y/N] " confirm; echo
    if [[ "${confirm,,}" != "y" ]]; then
      echo "Keeping existing $secret_file"
      return
    fi
  fi

  local value
  read -rs -p "Enter value for $secret_file: " value; echo
  if [[ -n "${env_var:-}" ]]; then
    printf '%s=%s\n' "$env_var" "$value" > "$secret_file"
  else
    printf '%s\n' "$value" > "$secret_file"
  fi
  chmod 644 "$secret_file"
}

copy_containers() {
  local service="$1"
  mkdir -p "$SYSTEMD_DIR/$service"
  cp -a "$ROOT_DIR/$service/containers/." "$SYSTEMD_DIR/$service/"
}

start_units() {
  local service="$1"
  for f in "$ROOT_DIR/$service"/containers/*.container; do
    [[ -e "$f" ]] || continue
    local unit
    unit=$(basename "$f" .container)
    echo "Starting $unit"
    systemctl --user start "$unit"
  done
}

install_service() {
  local service="$1"

  if [[ ! -d "$ROOT_DIR/$service" ]]; then
    echo "Service '$service' does not exist"
    exit 1
  fi

  echo "==> Installing $service"
  prompt_secret "$service"
  copy_containers "$service"
}

# Enable linger so rootless user services run without the user being logged in
loginctl enable-linger

# Determine which services to install
if [[ $# -eq 0 ]]; then
  mapfile -t SERVICES < <(
    find "$ROOT_DIR" \
      -mindepth 1 \
      -maxdepth 1 \
      -type d \
      -printf '%f\n' \
      | grep -Ev '^\.git$' \
      | sort
  )
else
  SERVICES=("$@")
fi

# Networking is a shared dependency; install it first regardless of what was requested.
# (Harmless if it appears twice — copy_containers is idempotent.)
SERVICES=("$NETWORKING" "${SERVICES[@]}")

for service in "${SERVICES[@]}"; do
  install_service "$service"
done

# One daemon-reload after all container files are in place
systemctl --user daemon-reload

# Start units for each service (networking declares no *.container, so nothing starts)
for service in "${SERVICES[@]}"; do
  start_units "$service"
done
