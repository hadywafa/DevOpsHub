# Kafka on K3s with Strimzi, Gateway API, Envoy Gateway and MetalLB

A clean local Kubernetes lab designed for K3s running in a Multipass VM.

## Architecture

```text
Ubuntu host
    |
    | local DNS (/etc/hosts)
    v
MetalLB virtual IP
    |
    v
Envoy Gateway LoadBalancer Service
    |
    v
Kubernetes Gateway API
    ├── ui.kafka.test       -> Kafbat UI
    ├── registry.kafka.test -> Schema Registry
    └── rest.kafka.test     -> Confluent REST Proxy
                                  |
                                  v
                     Strimzi-managed Kafka KRaft
```

Kafka stays internal to Kubernetes. HTTP clients enter through one Gateway API
`Gateway` backed by one MetalLB virtual IP.

## Components

- K3s local-path storage
- MetalLB in Layer 2 mode
- Envoy Gateway
- Gateway API `GatewayClass`, `Gateway`, and `HTTPRoute`
- Strimzi Cluster Operator
- Three dual-role KRaft Kafka nodes
- Confluent Schema Registry
- Confluent REST Proxy
- Kafbat UI

The K3s bundled Traefik and ServiceLB components are disabled to avoid two ingress
controllers and two LoadBalancer controllers competing for the same role.

## 1. Prepare K3s

Run from the Ubuntu host:

```bash
chmod +x prepare-k3s.sh restore-k3s-default-networking.sh install.sh uninstall.sh scripts/*.sh

MULTIPASS_VM=<your-vm-name> ./prepare-k3s.sh
```

The script creates this K3s drop-in file inside the Multipass VM:

```text
/etc/rancher/k3s/config.yaml.d/99-gateway-api-platform.yaml
```

It disables:

```yaml
disable+:
  - traefik
  - servicelb
```

## 2. Select the MetalLB virtual IP

The IP must be unused and on the same Layer 2 subnet as the Multipass K3s node.

Copy the example configuration:

```bash
cp config.env.example .lab.env
```

Update:

```dotenv
LOAD_BALANCER_IP=10.10.10.240
BASE_DOMAIN=kafka.test
```

When `.lab.env` is absent, `install.sh` derives a convenience candidate ending in
`.240` from the K3s node IPv4 address. Check that the address is unused before using
it on a shared network.

## 3. Install

```bash
./install.sh
```

The installer performs these stages:

1. Install MetalLB and configure a single-IP Layer 2 pool.
2. Install Envoy Gateway and Gateway API CRDs.
3. Install Strimzi.
4. Create or resume the same KRaft Kafka cluster.
5. Deploy topics, Schema Registry, REST Proxy, and Kafbat UI.
6. Create the Gateway API resources and request the MetalLB VIP.
7. Add local host mappings.

## Endpoints

```text
http://ui.kafka.test
http://registry.kafka.test
http://rest.kafka.test
```

## Test

```bash
./scripts/test.sh
```

## Kafka CLI

```bash
./scripts/kafka-shell.sh
```

Inside the ephemeral pod:

```bash
bin/kafka-topics.sh \
  --bootstrap-server lab-kafka-kafka-bootstrap:9092 \
  --list
```

## Status

```bash
./scripts/status.sh
```

## Stop and preserve data

```bash
./uninstall.sh
```

This removes Gateway routes and stateless lab workloads, stops Strimzi and Kafka
runtime pods, but preserves:

- Kafka and KafkaNodePool resources
- KRaft cluster ID
- Kafka secrets
- KafkaTopic resources
- messages and consumer offsets
- Schema Registry `_schemas` data
- PVCs

Resume the same cluster with:

```bash
./install.sh
```

## Delete all data

```bash
./uninstall.sh --purge-data
```

To also remove Envoy Gateway and MetalLB:

```bash
./uninstall.sh --purge-data --remove-platform
```

## Restore K3s bundled networking

After removing the platform components, restore Traefik and ServiceLB with:

```bash
MULTIPASS_VM=<your-vm-name> ./restore-k3s-default-networking.sh
```

## Important networking note

MetalLB Layer 2 mode requires the selected virtual IP to be reachable on the same
Layer 2 network as the K3s node. With Multipass on Linux this normally means choosing
an unused address from the VM node's subnet. If your Multipass backend uses a network
that does not permit Layer 2 address advertisement to the host, attach the VM to a
bridged network or use a route from the host to that network.
