#!/usr/bin/env bash
set -Eeuo pipefail

cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.."

: "${NAMESPACE:?NAMESPACE is required}"
: "${LOAD_BALANCER_IP:?LOAD_BALANCER_IP is required}"
: "${BASE_DOMAIN:?BASE_DOMAIN is required}"

mkdir -p .generated

sed \
  -e "s/__LOAD_BALANCER_IP__/${LOAD_BALANCER_IP//\//\\/}/g" \
  manifests/60-metallb-pool.yaml.tpl \
  > .generated/60-metallb-pool.yaml

sed \
  -e "s/__NAMESPACE__/${NAMESPACE//\//\\/}/g" \
  -e "s/__LOAD_BALANCER_IP__/${LOAD_BALANCER_IP//\//\\/}/g" \
  -e "s/__BASE_DOMAIN__/${BASE_DOMAIN//\//\\/}/g" \
  manifests/70-gateway-api.yaml.tpl \
  > .generated/70-gateway-api.yaml
