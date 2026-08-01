#!/usr/bin/env bash
set -Eeuo pipefail

MULTIPASS_VM="${MULTIPASS_VM:-}"

fail() {
  echo "ERROR: $*" >&2
  exit 1
}

command -v multipass >/dev/null 2>&1 || fail "multipass is required."

if [[ -z "$MULTIPASS_VM" ]]; then
  mapfile -t running_vms < <(
    multipass list --format csv 2>/dev/null |
      awk -F, 'NR > 1 && $2 == "Running" {print $1}'
  )
  [[ "${#running_vms[@]}" -eq 1 ]] || \
    fail "Set MULTIPASS_VM=<name>."
  MULTIPASS_VM="${running_vms[0]}"
fi

multipass exec "$MULTIPASS_VM" -- sudo rm -f \
  /etc/rancher/k3s/config.yaml.d/99-gateway-api-platform.yaml
multipass exec "$MULTIPASS_VM" -- sudo systemctl restart k3s

echo "K3s default Traefik and ServiceLB configuration was restored."
