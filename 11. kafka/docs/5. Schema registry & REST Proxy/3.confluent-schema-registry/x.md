# Kafka Avro Producer and Consumer in Java

We will use **SpecificRecord**: write an Avro schema, generate a strongly typed Java class, then use it with the normal Kafka producer and consumer.

```text
Producer Java object
        ↓
KafkaAvroSerializer
        ├── Register/find schema in Schema Registry
        └── Create: schema ID + Avro binary
        ↓
Kafka
        ↓
KafkaAvroDeserializer
        ├── Read schema ID
        └── Retrieve/cache schema
        ↓
Consumer Java object
```

The Avro serializer and deserializer perform this work in the Kafka client applications; Kafka brokers still transport bytes. ([Confluent Documentation](https://docs.confluent.io/platform/current/schema-registry/fundamentals/serdes-develop/serdes-avro.html?utm_source=chatgpt.com "Apache Avro for Kafka | Serialization, Schema, ..."))

---

## 1. Project structure

```text
kafka-avro-demo/
├── pom.xml
└── src/main/
    ├── avro/
    │   └── OrderCreated.avsc
    └── java/com/example/
        ├── AvroProducer.java
        └── AvroConsumer.java
```

---

## 2. Maven configuration

This example uses Kafka 4.3, Confluent 8.3 and Avro 1.12.1. Align versions with your actual platform support matrix. Confluent Platform 8.3 is based on Kafka 4.3, while Avro 1.12.1 is the current Apache Avro release. ([Confluent Documentation](https://docs.confluent.io/platform/current/release-notes/index.html?utm_source=chatgpt.com "Release Notes for Confluent Platform 8.3"))

```xml
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="
           http://maven.apache.org/POM/4.0.0
           https://maven.apache.org/xsd/maven-4.0.0.xsd">

    <modelVersion>4.0.0</modelVersion>

    <groupId>com.example</groupId>
    <artifactId>kafka-avro-demo</artifactId>
    <version>1.0.0</version>

    <properties>
        <maven.compiler.release>17</maven.compiler.release>
        <kafka.version>4.3.1</kafka.version>
        <confluent.version>8.3.0</confluent.version>
        <avro.version>1.12.1</avro.version>
    </properties>

    <repositories>
        <repository>
            <id>confluent</id>
            <url>https://packages.confluent.io/maven/</url>
        </repository>
    </repositories>

    <dependencies>
        <dependency>
            <groupId>org.apache.kafka</groupId>
            <artifactId>kafka-clients</artifactId>
            <version>${kafka.version}</version>
        </dependency>

        <dependency>
            <groupId>org.apache.avro</groupId>
            <artifactId>avro</artifactId>
            <version>${avro.version}</version>
        </dependency>

        <dependency>
            <groupId>io.confluent</groupId>
            <artifactId>kafka-avro-serializer</artifactId>
            <version>${confluent.version}</version>
        </dependency>
    </dependencies>

    <build>
        <plugins>
            <plugin>
                <groupId>org.apache.avro</groupId>
                <artifactId>avro-maven-plugin</artifactId>
                <version>${avro.version}</version>

                <executions>
                    <execution>
                        <phase>generate-sources</phase>
                        <goals>
                            <goal>schema</goal>
                        </goals>
                    </execution>
                </executions>
            </plugin>
        </plugins>
    </build>
</project>
```

The Avro Maven plugin generates Java classes from `.avsc` files during the Maven build. ([Apache Avro](https://avro.apache.org/docs/1.12.0/getting-started-java/?utm_source=chatgpt.com "Getting Started (Java) - Apache Avro"))

---

## 3. Create the Avro schema

Create:

```text
src/main/avro/OrderCreated.avsc
```

```json
{
  "type": "record",
  "name": "OrderCreated",
  "namespace": "com.example.events",
  "fields": [
    {
      "name": "orderId",
      "type": "string"
    },
    {
      "name": "amount",
      "type": "double"
    },
    {
      "name": "currency",
      "type": "string",
      "default": "AED"
    }
  ]
}
```

Generate the Java class:

```bash
mvn clean compile
```

Maven generates approximately:

```text
target/generated-sources/avro/
└── com/example/events/OrderCreated.java
```

For a .NET developer, this is similar to generating a strongly typed C# DTO from an IDL or contract.

---

# 4. Avro producer

```java
package com.example;

import com.example.events.OrderCreated;
import io.confluent.kafka.serializers.AbstractKafkaSchemaSerDeConfig;
import io.confluent.kafka.serializers.KafkaAvroSerializer;
import org.apache.kafka.clients.producer.KafkaProducer;
import org.apache.kafka.clients.producer.Producer;
import org.apache.kafka.clients.producer.ProducerConfig;
import org.apache.kafka.clients.producer.ProducerRecord;
import org.apache.kafka.clients.producer.RecordMetadata;
import org.apache.kafka.common.serialization.StringSerializer;

import java.util.Properties;

public class AvroProducer {

    private static final String TOPIC = "orders-avro";

    public static void main(String[] args) throws Exception {
        Properties properties = new Properties();

        properties.put(
            ProducerConfig.BOOTSTRAP_SERVERS_CONFIG,
            "localhost:9092"
        );

        properties.put(
            ProducerConfig.KEY_SERIALIZER_CLASS_CONFIG,
            StringSerializer.class.getName()
        );

        properties.put(
            ProducerConfig.VALUE_SERIALIZER_CLASS_CONFIG,
            KafkaAvroSerializer.class.getName()
        );

        properties.put(
            AbstractKafkaSchemaSerDeConfig.SCHEMA_REGISTRY_URL_CONFIG,
            "http://localhost:8081"
        );

        OrderCreated order = OrderCreated.newBuilder()
            .setOrderId("ORD-1001")
            .setAmount(250.0)
            .setCurrency("AED")
            .build();

        try (Producer<String, OrderCreated> producer =
                 new KafkaProducer<>(properties)) {

            ProducerRecord<String, OrderCreated> record =
                new ProducerRecord<>(
                    TOPIC,
                    order.getOrderId().toString(),
                    order
                );

            RecordMetadata metadata = producer.send(record).get();

            System.out.printf(
                "Produced order=%s partition=%d offset=%d%n",
                order.getOrderId(),
                metadata.partition(),
                metadata.offset()
            );
        }
    }
}
```

## What happens during `send()`

```text
OrderCreated object
        ↓
KafkaAvroSerializer
        ↓
Find its Avro schema
        ↓
Register/find schema under orders-avro-value
        ↓
Receive schema ID, for example 42
        ↓
Serialize object into Avro binary
        ↓
Send: magic byte + schema ID 42 + Avro payload
```

Schema registration is automatic by default. The default topic-based subject name for the value is `<topic>-value`. ([Confluent Documentation](https://docs.confluent.io/platform/current/schema-registry/fundamentals/serdes-develop/index.html?utm_source=chatgpt.com "Formats, Serializers, and Deserializers for Schema ..."))

Kafka receives the resulting bytes. It does not receive the Java object itself.

---

# 5. Avro consumer

```java
package com.example;

import com.example.events.OrderCreated;
import io.confluent.kafka.serializers.AbstractKafkaSchemaSerDeConfig;
import io.confluent.kafka.serializers.KafkaAvroDeserializer;
import io.confluent.kafka.serializers.KafkaAvroDeserializerConfig;
import org.apache.kafka.clients.consumer.Consumer;
import org.apache.kafka.clients.consumer.ConsumerConfig;
import org.apache.kafka.clients.consumer.ConsumerRecord;
import org.apache.kafka.clients.consumer.ConsumerRecords;
import org.apache.kafka.clients.consumer.KafkaConsumer;
import org.apache.kafka.common.serialization.StringDeserializer;

import java.time.Duration;
import java.util.List;
import java.util.Properties;

public class AvroConsumer {

    private static final String TOPIC = "orders-avro";

    public static void main(String[] args) {
        Properties properties = new Properties();

        properties.put(
            ConsumerConfig.BOOTSTRAP_SERVERS_CONFIG,
            "localhost:9092"
        );

        properties.put(
            ConsumerConfig.GROUP_ID_CONFIG,
            "orders-java-consumer"
        );

        properties.put(
            ConsumerConfig.AUTO_OFFSET_RESET_CONFIG,
            "earliest"
        );

        properties.put(
            ConsumerConfig.ENABLE_AUTO_COMMIT_CONFIG,
            false
        );

        properties.put(
            ConsumerConfig.KEY_DESERIALIZER_CLASS_CONFIG,
            StringDeserializer.class.getName()
        );

        properties.put(
            ConsumerConfig.VALUE_DESERIALIZER_CLASS_CONFIG,
            KafkaAvroDeserializer.class.getName()
        );

        properties.put(
            AbstractKafkaSchemaSerDeConfig.SCHEMA_REGISTRY_URL_CONFIG,
            "http://localhost:8081"
        );

        // Return generated OrderCreated instead of GenericRecord
        properties.put(
            KafkaAvroDeserializerConfig.SPECIFIC_AVRO_READER_CONFIG,
            true
        );

        try (Consumer<String, OrderCreated> consumer =
                 new KafkaConsumer<>(properties)) {

            consumer.subscribe(List.of(TOPIC));

            while (true) {
                ConsumerRecords<String, OrderCreated> records =
                    consumer.poll(Duration.ofSeconds(1));

                for (ConsumerRecord<String, OrderCreated> record : records) {
                    OrderCreated order = record.value();

                    System.out.printf(
                        "Consumed orderId=%s amount=%.2f currency=%s "
                            + "partition=%d offset=%d%n",
                        order.getOrderId(),
                        order.getAmount(),
                        order.getCurrency(),
                        record.partition(),
                        record.offset()
                    );
                }

                if (!records.isEmpty()) {
                    consumer.commitSync();
                }
            }
        }
    }
}
```

Setting `specific.avro.reader=true` tells the deserializer to return the generated `OrderCreated` class rather than a `GenericRecord`. ([Confluent Documentation](https://docs.confluent.io/platform/current/schema-registry/schema_registry_onprem_tutorial.html?utm_source=chatgpt.com "Tutorial: Use Schema Registry on Confluent Platform to ..."))

---

## What happens during `poll()`

```text
1. Kafka returns raw message bytes.

2. KafkaConsumer calls KafkaAvroDeserializer.

3. The deserializer reads the Confluent framing.

4. It extracts schema ID 42.

5. It checks its local schema cache.

6. If missing, it requests schema 42 from Schema Registry.

7. It decodes the Avro binary using that schema.

8. Because specific.avro.reader=true, it creates OrderCreated.

9. record.value() returns the strongly typed object.
```

The consumer does not guess that the message is Avro. It knows because you configured:

```java
KafkaAvroDeserializer.class
```

The schema ID tells that deserializer **which Avro schema** was used. Schema Registry clients cache retrieved schemas, avoiding a registry request for every record. ([Confluent Documentation](https://docs.confluent.io/platform/current/schema-registry/fundamentals/serdes-develop/index.html?utm_source=chatgpt.com "Formats, Serializers, and Deserializers for Schema ..."))

---

# GenericRecord variation

To consume dynamically instead of using the generated class:

```java
properties.put(
    KafkaAvroDeserializerConfig.SPECIFIC_AVRO_READER_CONFIG,
    false
);
```

Then:

```java
Consumer<String, GenericRecord> consumer =
    new KafkaConsumer<>(properties);

GenericRecord order = record.value();

String orderId = order.get("orderId").toString();
double amount = (Double) order.get("amount");
```

Use:

```text
SpecificRecord → normal business microservices with known contracts
GenericRecord  → generic tools handling unknown or changing schemas
```

The essential configuration is:

```text
Producer:
KafkaAvroSerializer + schema.registry.url

Consumer:
KafkaAvroDeserializer + schema.registry.url
specific.avro.reader=true for generated classes
```