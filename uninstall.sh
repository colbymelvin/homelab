#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SYSTEMD_DIR="$HOME/.config/containers/systemd/homelab"

stop_units() {
  local service="$1"
  for f in "$ROOT_DIR/$service"/containers/*.container; do
    [[ -e "$f" ]] || continue
    local unit
    unit=$(basename "$f" .container)
    echo "Stopping $unit"
    systemctl --user stop "$unit" || true
  done
}

remove_secret() {
  local service="$1"
  local secrets_file="$ROOT_DIR/$service/secrets.conf"
  # Explicit `return 0`: under `set -e`, a bare `return` propagates the failing
  # test's exit status and aborts the script.
  [[ -f "$secrets_file" ]] || return 0

  local path _env_var
  read -r path _env_var < <(sed -E 's/#.*$//' "$secrets_file" | awk 'NF{print;exit}')
  [[ -z "${path:-}" ]] && return 0

  rm -f "$ROOT_DIR/$service/$path"
}

remove_containers() {
  local service="$1"
  rm -rf "$SYSTEMD_DIR/$service"
}

uninstall_service() {
  local service="$1"

  if [[ ! -d "$ROOT_DIR/$service" ]]; then
    echo "Service '$service' does not exist"
    exit 1
  fi

  echo "==> Uninstalling $service"
  remove_containers "$service"
  remove_secret "$service"
}

# Determine which services to uninstall
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

# Stop units before removing anything so systemd sees a clean shutdown
for service in "${SERVICES[@]}"; do
  stop_units "$service"
done

for service in "${SERVICES[@]}"; do
  uninstall_service "$service"
done

# One daemon-reload after all removals
systemctl --user daemon-reload
