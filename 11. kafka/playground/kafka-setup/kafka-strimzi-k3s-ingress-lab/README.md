# Kafka on K3s — Strimzi, Schema Registry, REST Proxy and Traefik Ingress

A clean local Kubernetes lab designed for **K3s running inside Multipass**.

## Components

- Strimzi Cluster Operator `1.1.0`
- Apache Kafka `4.3.0`, KRaft mode
- Three dual-role Kafka nodes
- Persistent `local-path` PVCs
- Strimzi Topic Operator
- Confluent Schema Registry `8.3.0`
- Confluent REST Proxy `8.3.0`
- Kafbat UI `1.5.0`
- K3s built-in Traefik as the HTTP ingress gateway

## Deliberately removed

- No Kafka `NodePort`
- No `kubectl port-forward`
- No persistent Kafka client Deployment
- No Strimzi User Operator because this lab does not define `KafkaUser` resources
- No additional ingress controller or API gateway

Kafka uses a binary TCP protocol, not HTTP. The base lab therefore keeps Kafka
private inside Kubernetes and exposes the HTTP-native services through Traefik.
An ephemeral Kafka CLI pod is created only when you request a shell.

## Traffic flow

```text
Ubuntu host
    |
    | HTTP using nip.io hostnames
    v
Multipass VM IP :80
    |
    v
K3s Traefik ingress gateway
    ├── ui.kafka.<VM-IP>.nip.io       -> Kafbat UI
    ├── registry.kafka.<VM-IP>.nip.io -> Schema Registry
    └── rest.kafka.<VM-IP>.nip.io     -> REST Proxy
                                                |
                                                v
                                  lab-kafka-kafka-bootstrap:9092
                                                |
                              +-----------------+-----------------+
                              |                 |                 |
                           Kafka 0           Kafka 1           Kafka 2
                        broker/controller  broker/controller  broker/controller
```

## Requirements

- Multipass VM reachable from the Ubuntu host
- K3s with its default Traefik controller enabled
- `kubectl`, Helm 3 and `curl`
- A default StorageClass; standard K3s provides `local-path`
- About 4 GiB of free RAM inside the VM

## Install or resume

```bash
chmod +x install.sh uninstall.sh scripts/*.sh
./install.sh
```

The script detects the K3s node IP and uses `nip.io`, so `/etc/hosts` changes are
not required.

Example URLs:

```text
http://ui.kafka.10.10.10.20.nip.io
http://registry.kafka.10.10.10.20.nip.io
http://rest.kafka.10.10.10.20.nip.io
```

Override the generated domain when needed:

```bash
BASE_DOMAIN=kafka.lab.example ./install.sh
```

## Kafka CLI

Kafka remains internal-only. Open an ephemeral CLI pod:

```bash
./scripts/kafka-shell.sh
```

The pod is removed automatically when the shell exits.

## End-to-end Avro test

```bash
./scripts/test.sh
```

The test reaches REST Proxy and Schema Registry through Traefik, produces an
Avro record, registers its schema, and consumes the record back.

## Status

```bash
./scripts/status.sh
```

## Stop and preserve data

```bash
./uninstall.sh
```

This removes ingress and stateless workloads, uninstalls the Strimzi operator,
and stops Kafka runtime pods. It preserves:

- `Kafka` and `KafkaNodePool` resources
- KRaft cluster ID
- Kafka topics and offsets
- `_schemas`
- generated Secrets
- PVCs and broker data

Resume using:

```bash
./install.sh
```

## Permanent reset

```bash
./uninstall.sh --purge-data
```

This deletes the namespace and all Kafka data. The next installation creates a
new empty cluster and a new KRaft cluster ID.

## Important limitation

The K3s `local-path` provisioner stores volumes on the Multipass VM node. Data
survives this lab's preserve workflow, but deleting or recreating the Multipass
VM can destroy the underlying files.
