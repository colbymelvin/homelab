#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

uninstall_service() {
  local service="$1"
  local service_dir="$ROOT_DIR/$service"
  local script="$service_dir/uninstall.sh"

  if [[ ! -d "$service_dir" ]]; then
    echo "Service '$service' does not exist"
    exit 1
  fi

  if [[ ! -x "$script" ]]; then
    echo "Skipping '$service' (no executable uninstall.sh)"
    return
  fi

  echo "Uninstalling $service"
  (cd "$service_dir" && ./uninstall.sh)
}

# If no args, uninstall everything (each child directory)
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

for service in "${SERVICES[@]}"; do
  uninstall_service "$service"
done

