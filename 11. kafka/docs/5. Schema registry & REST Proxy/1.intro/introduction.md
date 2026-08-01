# Kafka Schema Registry, Avro and REST Proxy


Imagine we are building an order-processing system:

```text
Order Application → Kafka → Billing Application
                          → Notification Application
                          → Analytics Application
```

Kafka’s responsibility is simple:

> Receive bytes, store bytes, replicate bytes and deliver bytes.

Kafka does not know whether those bytes contain JSON, Avro, Protobuf, text, an image or corrupted data.

That separation is intentional.

- Kafka handles transportation;
- applications handle the meaning and structure of the data.

---

## 1. The Problem begins with an agreement

The producer sends an order:

```json
{
  "orderId": "ORD-1001",
  "customerName": "Hady",
  "amount": 250.0
}
```

Every consumer assumes:

```text
orderId      = string
customerName = string
amount       = double
```

But this agreement currently exists only inside the producer and consumer code.

One day, the producer changes the event:

```json
{
  "orderId": "ORD-1001",
  "customerName": "Hady",
  "amount": "250 AED"
}
```

Kafka accepts it. It is still a valid sequence of bytes.

But the billing consumer expects `amount` to be a number, so it may fail.

The company needs a central contract that defines:

```text
Which fields exist?
What is the type of every field?
Which fields are required?
Which changes are safe?
Which changes must be rejected?
```

That contract is called a **schema**.

---
## 2. What Schema Registry does


> **Schema Registry** is the service that stores, versions and checks these schemas as they evolve. ([docs.confluent.io](https://docs.confluent.io/platform/current/schema-registry/index.html?utm_source=chatgpt.com 'Schema Registry for Confluent Platform'))



![[Pasted image 20260729115519.png]]

![[Pasted image 20260729115601.png]]


Schema Registry is a separate service that:

- stores schemas;
- assigns IDs and versions to them;
- checks whether new schema versions are compatible;
- allows producers and consumers to retrieve schemas.

It is not normally between the producer and Kafka.

---



## 3. Why Avro appears in the architecture

A schema alone is only a description. We also need a serialization format that uses that description to convert objects into bytes.

`Avro` is one such format.

An Avro schema might look like this:

```json
{
  "type": "record",
  "name": "OrderCreated",
  "namespace": "com.company.orders",
  "fields": [
    {
      "name": "orderId",
      "type": "string"
    },
    {
      "name": "customerName",
      "type": "string"
    },
    {
      "name": "amount",
      "type": "double"
    }
  ]
}
```

This declares:

```text
Record: OrderCreated

orderId      must be string
customerName must be string
amount       must be double
```

Avro then uses this schema to encode an object into compact binary data.

Avro binary does not repeatedly write field names such as `orderId`, `customerName` and `amount` inside every message. It writes the values according to the field order and types defined by the schema.

That makes Avro data relatively compact and fast, but it also means the reader needs the writer’s schema to understand the bytes. Avro supports schema resolution between the schema used by the producer and the schema expected by the consumer. ([Apache Avro](https://avro.apache.org/docs/1.12.0/specification/?utm_source=chatgpt.com 'Specification | Apache Avro'))

This combination makes Avro attractive for Kafka:

```text
Compact binary messages
Strong field types
Language-independent schemas
Schema evolution
Support for generated classes or generic records
Mature Schema Registry integration
```

---

### Avro is not mandatory

Avro is not required by Kafka.

Kafka can carry any bytes:

```text
String
Plain JSON
Avro
Protobuf
JSON Schema
XML
Images
Compressed data
Custom binary data
```

Avro is also not the only format supported by Confluent Schema Registry.

Schema Registry supports three major schema formats:

```text
Avro
Protobuf
JSON Schema
```

All three can be registered, versioned and checked for compatibility. ([docs.confluent.io](https://docs.confluent.io/platform/current/schema-registry/fundamentals/serdes-develop/index.html?utm_source=chatgpt.com 'Formats, Serializers, and Deserializers for Schema ...'))

Therefore, these architectures are all possible:

```text
Producer → Avro Serializer → Kafka
Producer → Protobuf Serializer → Kafka
Producer → JSON Schema Serializer → Kafka
```

But this architecture does not automatically use Schema Registry:

```text
Producer → normal JSON string → Kafka
```

A plain JSON producer using `StringSerializer` simply sends text. 
Schema Registry will not become involved unless the application uses a Schema Registry-aware JSON Schema serializer or calls Schema Registry manually.

---

### The programming language does not select the data format

A Java producer does not automatically send Avro simply because it is written in Java.

The producer format depends on the configured serializer.

For example:

```properties
value.serializer=org.apache.kafka.common.serialization.StringSerializer
```

means:

```text
Java object/string
        ↓
StringSerializer
        ↓
UTF-8 string bytes
        ↓
Kafka
```

This configuration:

```properties
value.serializer=org.apache.kafka.common.serialization.ByteArraySerializer
```

means:

```text
byte[] → Kafka
```

And this configuration:

```properties
value.serializer=io.confluent.kafka.serializers.KafkaAvroSerializer
```

means:

```text
Java object
     ↓
KafkaAvroSerializer
     ├── communicates with Schema Registry
     └── produces Avro bytes for Kafka
```

The application language and serialization format are independent decisions.

```text
Java producer       can send Avro, JSON, Protobuf or strings.
.NET producer       can send Avro, JSON, Protobuf or strings.
Python producer     can send Avro, JSON, Protobuf or strings.
```

## 4. The Roles of the components

### Kafka Core
![[Pasted image 20260730124015.png]]

### Confluent Schema Registry

![[Pasted image 20260730124220.png]]

### Confluent REST Proxy (for non-java producer/consumer)

![[Pasted image 20260730124310.png]]

Keep these responsibilities separate:

```text
**Kafka**
- Stores and transports bytes.

**Schema**
- Defines the structure of an event.

**Avro / Protobuf / JSON Schema**
- Defines how structured data is represented and serialized.

**Schema Registry**
- Stores schemas, gives them IDs and checks compatibility.

**Serializer**
- Converts an application object into bytes.

**Deserializer**
- Converts bytes back into an application object.
```




---

## 5. Complete producer flow

Suppose a Java or .NET producer creates:

```text
OrderCreated
├── orderId = "ORD-1001"
└── amount  = 250.0
```

The configured Avro serializer performs the following work:

```text
Application object
        ↓
Avro Serializer
        ↓
Find the Avro schema
        ↓
Register or locate it in Schema Registry
        ↓
Receive a schema ID, for example 42
        ↓
Convert the object into Avro binary
```

The final Kafka value is approximately:

```text
┌────────────┬───────────────┬─────────────────────┐
│ Magic byte │ Schema ID 42  │ Avro binary payload │
└────────────┴───────────────┴─────────────────────┘
```

The complete schema is not copied into every message. Only its small ID is included.

Kafka stores these bytes without understanding that they contain an order.

---

###  Who validates the producer data?

Different components validate different things.

#### Avro serializer

The serializer checks whether the object can be encoded according to the schema.

If the schema expects:

```text
amount → double
```

but the application supplies:

```text
amount → "250 AED"
```

serialization fails, and the valid Avro message is not produced.

#### Schema Registry

Schema Registry validates the schema itself and its evolution.

For example, adding:

```text
currency → string, default "AED"
```

may be accepted.

Changing:

```text
amount: double
```

to:

```text
amount: string
```

may be rejected because it could break consumers.

#### Kafka broker

Kafka validates Kafka-level details such as request structure, authentication, message size and checksums.

It does not normally validate business fields such as:

```text
Is amount really a double?
Does orderId exist?
```

> Confluent Platform has a feature to let Kafka validate Schema ID
---

## 7. Complete consumer flow

The consumer must already be configured with the correct deserializer:

```text
KafkaAvroDeserializer
```

This configuration tells the consumer:

> Values from this topic are expected to use the Confluent Avro format.

Kafka does not automatically announce:

```text
“This record is Avro.”
```

The topic contract and consumer configuration establish that expectation.

When the consumer calls `poll()`, the flow is:

```text
Kafka returns raw bytes
        ↓
Kafka client calls KafkaAvroDeserializer
        ↓
Deserializer checks the message framing
        ↓
Reads schema ID 42
        ↓
Checks whether schema 42 is cached
        ↓
If not cached, retrieves it from Schema Registry
        ↓
Uses the schema to decode the Avro payload
        ↓
Returns an OrderCreated object
```

The consumer normally retrieves a schema only the first time it sees that schema ID. Later messages use the cached schema.

---

### How does the consumer know it is Avro?

Mainly because the application was configured with:

```text
KafkaAvroDeserializer
```

The deserializer expects a specific structure:

```text
Magic byte + Schema ID + Avro payload
```

The magic byte tells it that the expected Schema Registry-aware framing is present. The schema ID tells it which schema was used.

But the consumer does not inspect random bytes and intelligently guess:

```text
Maybe this is Avro
Maybe this is JSON
Maybe this is Protobuf
```

The configured deserializer decides how the payload should be interpreted.

For example:

```text
KafkaAvroDeserializer       → expects Avro
ProtobufDeserializer        → expects Protobuf
JsonSchemaDeserializer      → expects JSON Schema
```

---

###  What happens when formats do not match?

#### Producer sends Avro, consumer expects Avro

```text
Success
```

#### Producer sends plain JSON, consumer expects Avro

The Avro deserializer expects:

```text
Magic byte + schema ID + Avro payload
```

but receives:

```json
{"orderId":"ORD-1001"}
```

Deserialization fails, often with an error such as an unknown magic byte.

#### Producer sends Avro, consumer uses StringDeserializer

The consumer interprets binary Avro bytes as text and receives unreadable or incorrect data.

Therefore, teams normally define a clear contract:

```text
Topic: orders
Key format: String
Value format: Avro
Schema: OrderCreated
```

---



---



## REST Proxy enters the story

Native Kafka clients communicate using the Kafka protocol:

```text
Java application   ──► Kafka protocol ──► Kafka
.NET application   ──► Kafka protocol ──► Kafka
Python application ──► Kafka protocol ──► Kafka
```

But some systems cannot or should not run a native Kafka client.

Examples include:

```text
Legacy applications
Simple shell scripts
Systems restricted to HTTP
Some serverless functions
External integrations
Applications without an appropriate Kafka client
```

REST Proxy provides an HTTP interface in front of Kafka:

```text
HTTP Application ──► REST Proxy ──► Kafka Cluster
```

REST Proxy internally acts as a Kafka client. It can produce records, consume records and perform some Kafka administrative operations without requiring the caller to use the native Kafka protocol. ([docs.confluent.io](https://docs.confluent.io/platform/current/kafka-rest/index.html?utm_source=chatgpt.com 'Confluent REST Proxy for Apache Kafka on ...'))

---

### Producing through REST Proxy

The application sends an HTTP request:

```text
HTTP POST ──► REST Proxy ──► Kafka Producer API ──► Kafka topic
```

For example, conceptually:

```http
POST /topics/orders
Content-Type: application/vnd.kafka.avro.v2+json
```

The request may contain:

```json
{
  "value_schema": "...Avro schema...",
  "records": [
    {
      "value": {
        "orderId": "ORD-1001",
        "customerName": "Hady",
        "amount": 250.0
      }
    }
  ]
}
```

REST Proxy then:

```text
1. Receives the HTTP JSON request.
2. Extracts the order data.
3. Registers or looks up the schema.
4. Serializes the order into Avro.
5. Uses a native Kafka producer internally.
6. Sends the record to Kafka.
7. Returns partition and offset information.
```

The final record stored in Kafka uses the normal schema-aware format:

```text
Schema ID + Avro payload
```

A normal Java or .NET Avro consumer can consume it. The consumer does not need to know that the record originally entered through REST Proxy.

REST Proxy supports Avro, Protobuf and JSON Schema serialization, as well as other embedded data representations supported by its API. ([docs.confluent.io](https://docs.confluent.io/platform/current/kafka-rest/api.html?utm_source=chatgpt.com 'API Reference for Confluent REST Proxy'))

---

### Consuming through REST Proxy

Consuming is more involved because a Kafka consumer is stateful.

A consumer has:

```text
Consumer group
Subscriptions
Partition assignments
Current positions
Committed offsets
Rebalances
```

Therefore, consuming through REST Proxy usually follows a lifecycle.

#### 1. Create a consumer instance

```text
POST /consumers/order-service-group
```

REST Proxy creates an internal Kafka consumer.

#### 2. Subscribe it to topics

```text
POST /consumers/order-service-group/instances/consumer-1/subscription
```

For example:

```json
{
  "topics": ["orders"]
}
```

#### 3. Fetch records

```text
GET /consumers/order-service-group/instances/consumer-1/records
```

REST Proxy:

```text
Polls Kafka
Reads the schema ID
Retrieves the schema if necessary
Deserializes the data
Returns an HTTP-friendly response
```

#### 4. Commit offsets

The application can use REST endpoints to commit processed offsets.

#### 5. Delete the consumer instance

When finished, the application deletes the REST consumer instance so REST Proxy can release its resources.

REST Proxy consumer instances are stateful and tied to a particular REST Proxy instance, which must be considered when placing multiple proxy instances behind a load balancer. ([docs.confluent.io](https://docs.confluent.io/platform/current/kafka-rest/api.html?utm_source=chatgpt.com 'API Reference for Confluent REST Proxy'))

---

### Native client versus REST Proxy

For a normal Java or .NET service, the preferred architecture is usually:

```text
Application → Native Kafka Client → Kafka
```

This provides direct access to:

```text
Producer batching
Consumer polling
Rebalancing
Transactions
Offset management
Kafka security features
Better control over performance
```

REST Proxy is more suitable when HTTP compatibility is the primary requirement:

```text
Application → HTTP → REST Proxy → Kafka
```

REST Proxy introduces another network hop and another service to deploy and operate, but it makes Kafka accessible to applications that cannot conveniently use the Kafka protocol.

---




---

## Final architecture

### For Kafka Clients (Producer/Consumer) applications:

```text
Producer Application
        ↓
Avro Serializer
        ├── register/find schema ──► Schema Registry
        └── schema ID + Avro data ──► Kafka
                                          ↓
Consumer Application                      │
        ↑                                 │
Avro Deserializer ◄───────────────────────┘
        ├── read schema ID
        └── retrieve/cache schema ─────► Schema Registry
```

![[Pasted image 20260730124220.png]]



### For HTTP applications:

```text
HTTP Application → REST Proxy → Kafka
                         │
                         └────► Schema Registry
```

![[Pasted image 20260730124310.png]]


> **Kafka transports bytes. 
> The serializer decides the format. 
> Avro is a compact schema-based format but is not mandatory. 
> Schema Registry stores and protects the contracts. 
> The consumer knows to use Avro because it is configured with an Avro deserializer, which reads the schema ID and retrieves the required schema. 
> REST Proxy provides the same Kafka capabilities through HTTP when a native client is not suitable.**