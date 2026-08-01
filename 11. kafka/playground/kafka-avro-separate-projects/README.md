# Kafka Avro Java — separate producer and consumer projects

Defaults:

- Kafka: `localhost:9092`
- Schema Registry: `http://localhost:8081`
- Topic: `orders-avro`

## Run consumer

```bash
cd kafka-avro-consumer
mvn clean compile exec:java
```

## Run producer in another terminal

```bash
cd kafka-avro-producer
mvn clean compile exec:java
```

Optional environment variables:

```bash
export KAFKA_BOOTSTRAP_SERVERS=localhost:9092
export SCHEMA_REGISTRY_URL=http://localhost:8081
export KAFKA_TOPIC=orders-avro
export KAFKA_CONSUMER_GROUP=orders-avro-java-consumer
```
