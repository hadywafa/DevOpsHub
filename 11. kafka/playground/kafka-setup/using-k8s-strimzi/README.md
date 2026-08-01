# Kafka on Kubernetes Lab — Strimzi + Schema Registry + REST Proxy

This lab deploys:

- Strimzi Cluster Operator 1.1.0
- Apache Kafka 4.3.0 in KRaft mode
- Three dual-role Kafka nodes: broker + controller
- Persistent storage: one 5 Gi PVC per Kafka node
- Strimzi Topic Operator and User Operator
- Confluent Schema Registry 8.3.0
- Confluent REST Proxy 8.3.0
- Kafbat UI 1.5.0
- A persistent Kafka CLI client pod

## Architecture

```text
Host browser / curl
       |
       | kubectl port-forward
       v
+----------------------+      +----------------------+
| Kafbat UI :8080      |      | REST Proxy :8082     |
+----------+-----------+      +----------+-----------+
           |                             |
           |                             +-------------------+
           |                                                 |
           v                                                 v
+----------------------+                          +----------------------+
| Schema Registry      |------------------------->| Kafka bootstrap      |
| :8081                |  stores schemas in       | :9092 internal       |
+----------------------+  Kafka topic _schemas    +----------+-----------+
                                                               |
                                                +--------------+--------------+
                                                |              |              |
                                         +------v------+ +-----v-------+ +----v--------+
                                         | Kafka 0     | | Kafka 1     | | Kafka 2     |
                                         | broker +    | | broker +    | | broker +    |
                                         | controller  | | controller  | | controller  |
                                         +-------------+ +-------------+ +-------------+
```

## Requirements

- A reachable Kubernetes cluster
- `kubectl`
- Helm 3
- A default Kubernetes `StorageClass`
- Approximately 5–6 GiB of available cluster memory for the complete lab
- `curl` for the end-to-end REST test

## Install

```bash
chmod +x install.sh uninstall.sh scripts/*.sh
./install.sh
```

Use a different namespace:

```bash
NAMESPACE=my-kafka-lab ./install.sh
```

## Check status

```bash
./scripts/status.sh
```

## Open the HTTP services

```bash
./scripts/port-forward.sh
```

Then open:

- Kafbat UI: http://127.0.0.1:8080
- Schema Registry: http://127.0.0.1:8081
- REST Proxy: http://127.0.0.1:8082

Port forwarding intentionally covers only HTTP services. Kafka clients receive broker addresses in Kafka metadata, so a single `kubectl port-forward` to the bootstrap service is not a correct general external-Kafka solution.

## Kafka CLI shell inside Kubernetes

```bash
./scripts/kafka-shell.sh
```

Inside the client pod:

```bash
bin/kafka-topics.sh \
  --bootstrap-server lab-kafka-kafka-bootstrap:9092 \
  --list
```

Producer:

```bash
bin/kafka-console-producer.sh \
  --bootstrap-server lab-kafka-kafka-bootstrap:9092 \
  --topic orders
```

Consumer:

```bash
bin/kafka-console-consumer.sh \
  --bootstrap-server lab-kafka-kafka-bootstrap:9092 \
  --topic orders \
  --from-beginning
```

## End-to-end Schema Registry and REST Proxy test

```bash
./scripts/test.sh
```

The test:

1. Produces an Avro record through REST Proxy.
2. Causes the Avro schema to be registered in Schema Registry.
3. Creates a REST consumer.
4. Reads the Avro record back through REST Proxy.

## External Kafka access

The Kafka manifest includes a plaintext `nodeport` listener for lab use.

Get its bootstrap address:

```bash
kubectl get kafka lab-kafka -n kafka-lab \
  -o=jsonpath='{.status.listeners[?(@.name=="external")].bootstrapServers}{"\n"}'
```

Then use the returned address with your Ubuntu Kafka CLI:

```bash
kafka-topics.sh --bootstrap-server <returned-host:port> --list
```

Notes:

- On Minikube, the address normally uses the Minikube node IP.
- On bare-metal, k3s or routable worker nodes, NodePort usually works directly.
- For kind, NodePort requires suitable host port mappings when the kind cluster is created. The in-cluster Kafka client pod always works regardless of this external networking detail.

## Storage

Kafka data uses three PVCs. `deleteClaim: false` protects the data if the Kafka custom resource is deleted accidentally.

List PVCs:

```bash
kubectl get pvc -n kafka-lab
```

## Uninstall

Keep PVC data:

```bash
./uninstall.sh
```

Delete everything, including PVC data and the namespace:

```bash
./uninstall.sh --purge-data
```

## Lab security warning

This environment deliberately uses plaintext Kafka and unauthenticated HTTP endpoints to keep the learning flow simple. Do not use these manifests as a production security baseline. A production design should add TLS, Kafka client authentication, authorization/ACLs, authenticated Schema Registry and REST Proxy, NetworkPolicies, external secrets, backup and monitoring.
