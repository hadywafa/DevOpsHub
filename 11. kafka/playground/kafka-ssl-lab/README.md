# Kafka KRaft TLS Lab

Three Apache Kafka 4.3.1 combined broker/controller nodes with TLS on:

- client-to-broker traffic
- inter-broker traffic
- KRaft controller traffic
- Kafbat UI connection

This lab uses one-way TLS: clients verify broker certificates, but brokers do not require client certificates.

## Requirements

- Docker and Docker Compose
- JDK 17+ (`keytool`), Java 21 recommended

## Start

```bash
./start.sh
docker compose ps
./test-cli.sh
```

Kafbat UI: http://localhost:8080

External bootstrap servers:

```text
localhost:29093,localhost:39093,localhost:49093
```

## Inspect a broker certificate

```bash
keytool -list -v \
  -keystore secrets/kafka-1.keystore.p12 \
  -storetype PKCS12 \
  -storepass changeit \
  -alias kafka-1
```

Check the SAN list contains `kafka-1`, `localhost`, and `127.0.0.1`.

## Test TLS handshake

```bash
openssl s_client \
  -connect localhost:29093 \
  -CAfile secrets/ca.crt \
  -verify_hostname localhost \
  </dev/null
```

## Test that plaintext fails on the TLS listener

```bash
docker compose exec kafka-1 \
  /opt/kafka/bin/kafka-topics.sh \
  --bootstrap-server kafka-1:19093 \
  --list
```

The command intentionally omits `--command-config` and should fail because it sends plaintext to a TLS listener.

## Host Kafka CLI

If Kafka CLI is installed on the host:

```bash
kafka-topics.sh \
  --bootstrap-server localhost:29093 \
  --command-config client/client.properties \
  --list
```

## Stop / reset

```bash
./stop.sh
./reset.sh
```

`reset.sh` removes data volumes and regeneratable lab certificates.
