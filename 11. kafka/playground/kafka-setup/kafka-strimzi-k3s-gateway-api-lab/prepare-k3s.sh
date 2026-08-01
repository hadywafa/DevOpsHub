#!/usr/bin/env bash
set -Eeuo pipefail

# Run this script on the Ubuntu host where Multipass is installed.
# It disables the K3s bundled Traefik and ServiceLB components so that
# Envoy Gateway and MetalLB are the only north-south networking stack.

MULTIPASS_VM="${MULTIPASS_VM:-}"

fail() {
  echo "ERROR: $*" >&2
  exit 1
}

command -v multipass >/dev/null 2>&1 || fail "multipass is required."
command -v kubectl >/dev/null 2>&1 || fail "kubectl is required."

if [[ -z "$MULTIPASS_VM" ]]; then
  mapfile -t running_vms < <(
    multipass list --format csv 2>/dev/null |
      awk -F, 'NR > 1 && $2 == "Running" {print $1}'
  )

  case "${#running_vms[@]}" in
    0) fail "No running Multipass VM was found. Set MULTIPASS_VM explicitly." ;;
    1) MULTIPASS_VM="${running_vms[0]}" ;;
    *)
      printf 'Running Multipass VMs:\n' >&2
      printf '  %s\n' "${running_vms[@]}" >&2
      fail "More than one VM is running. Set MULTIPASS_VM=<name>."
      ;;
  esac
fi

echo "Configuring K3s VM: $MULTIPASS_VM"

# K3s supports drop-in configuration files. The '+' suffix appends to any
# existing disable list instead of replacing it.
cat <<'YAML' | multipass exec "$MULTIPASS_VM" -- sudo tee \
  /tmp/99-gateway-api-platform.yaml >/dev/null
disable+:
  - traefik
  - servicelb
YAML

multipass exec "$MULTIPASS_VM" -- sudo mkdir -p \
  /etc/rancher/k3s/config.yaml.d

multipass exec "$MULTIPASS_VM" -- sudo mv \
  /tmp/99-gateway-api-platform.yaml \
  /etc/rancher/k3s/config.yaml.d/99-gateway-api-platform.yaml

multipass exec "$MULTIPASS_VM" -- sudo systemctl restart k3s

echo "Waiting for K3s to become reachable..."
for _ in $(seq 1 90); do
  if kubectl get nodes >/dev/null 2>&1; then
    break
  fi
  sleep 2
done

kubectl wait node --all --for=condition=Ready --timeout=5m

# Disabled packaged components are actively removed by K3s. Wait briefly so
# the installation script does not race their deletion.
for _ in $(seq 1 60); do
  traefik_count="$(kubectl get deployment -n kube-system traefik \
    --ignore-not-found -o name 2>/dev/null | wc -l)"
  svclb_count="$(kubectl get daemonset -n kube-system -o name 2>/dev/null |
    grep -c '/svclb-' || true)"

  if [[ "$traefik_count" -eq 0 && "$svclb_count" -eq 0 ]]; then
    break
  fi
  sleep 2
done

echo
echo "K3s is ready for Envoy Gateway + MetalLB."
echo "Traefik and ServiceLB are disabled through:"
echo "  /etc/rancher/k3s/config.yaml.d/99-gateway-api-platform.yaml"
