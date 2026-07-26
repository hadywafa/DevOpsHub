You were correct: **producers and consumers are normally outside the Kafka cluster**.

In the labs, we ran the Kafka CLI tools inside a broker container only because the Kafka image already contains those command-line tools. That does **not** make them part of the broker process.

# The correct architecture

```text
Producer application
        |
        v
Kafka broker cluster
        |
        v
Consumer application
```

More accurately:

```text
Producer clients                  Consumer clients
----------------                  ----------------
Java service                      Java service
.NET application                  .NET application
Python application                Python application
Kafka CLI producer                Kafka CLI consumer
Kafka Connect                     Kafka Streams app
       \                              /
        \                            /
         v                          v
        Kafka broker cluster
        --------------------
        Broker 1
        Broker 2
        Broker 3
```

The broker cluster stores and serves Kafka records.

The producer and consumer are client applications.

---

# 1. What runs inside a Kafka broker container?

The main process inside the container is the Kafka broker:

```text
Kafka broker JVM
```

In KRaft combined mode, that process may also act as:

```text
Broker + KRaft controller
```

The image also contains administration and testing programs:

```text
/opt/kafka/bin/kafka-topics.sh
/opt/kafka/bin/kafka-console-producer.sh
/opt/kafka/bin/kafka-console-consumer.sh
/opt/kafka/bin/kafka-consumer-groups.sh
```

These files are just tools installed in the image.

When you run:

```bash
docker compose exec kafka-1 \
  /opt/kafka/bin/kafka-console-producer.sh \
  --bootstrap-server kafka-1:19092 \
  --topic orders
```

Docker starts a **new process** inside the existing container:

```text
kafka-1 container
├── Kafka broker process
└── Console producer process
```

They are separate JVM processes.

The console producer is not part of the broker.

---

# 2. Why did we run the CLI inside `kafka-1`?

Only for convenience.

The Kafka Docker image already contains:

```text
Kafka CLI binaries
Java runtime
Kafka client libraries
```

Therefore, we did not need to install Kafka tools on your laptop.

This:

```bash
docker compose exec kafka-1 kafka-console-producer.sh ...
```

means:

> Use the Kafka client tool installed inside the `kafka-1` container.

It does not mean:

> The Kafka producer logically belongs inside broker 1.

---

# 3. The producer can run anywhere

A producer can run:

- On your laptop
- In another Docker container
- In Kubernetes
- On a virtual machine
- In a backend application
- In a different data centre, if networking allows it
- Inside the Kafka broker container for testing

Example external producer:

```text
Your .NET application
    |
    | connects to localhost:29092
    v
Kafka cluster
```

Example Docker container producer:

```text
orders-service container
    |
    | connects to kafka-1:19092
    v
Kafka cluster
```

Example Kubernetes producer:

```text
orders-service Pod
    |
    | connects to kafka-bootstrap.kafka.svc:9092
    v
Kafka brokers
```

The only requirement is that the producer can reach the broker addresses Kafka advertises.

---

# 4. The consumer can also run anywhere

The same applies to consumers.

A consumer is normally an application separate from Kafka:

```text
Kafka cluster
    |
    v
orders-service consumer
```

Examples:

```text
orders-service
payment-service
analytics-service
notification-service
```

Each service may use its own consumer group.

```text
Topic: orders

Group: payment-service
Group: analytics-service
Group: notification-service
```

Each group tracks its own offsets.

---

# 5. What happened in your CLI lab?

You ran:

```bash
docker compose exec kafka-1 \
  /opt/kafka/bin/kafka-console-consumer.sh \
  --bootstrap-server kafka-1:19092 \
  --topic orders
```

Runtime view:

```text
Docker host
│
├── kafka-1 container
│   ├── Kafka broker JVM
│   └── Console consumer JVM
│
├── kafka-2 container
│   └── Kafka broker JVM
│
└── kafka-3 container
    └── Kafka broker JVM
```

Although the consumer process happened to run inside the `kafka-1` container, it could consume data from partitions whose leaders are on any broker.

For example:

```text
Console consumer running inside kafka-1 container
    |
    ├── reads partition 0 from broker 2
    ├── reads partition 1 from broker 3
    └── reads partition 2 from broker 1
```

The container location does not determine which broker serves the data.

---

# 6. `--bootstrap-server` does not mean “use only this broker”

This command:

```bash
--bootstrap-server kafka-1:19092
```

means:

> Contact broker 1 initially so I can discover the cluster.

It does not mean:

> Send every request permanently through broker 1.

The actual flow is:

```text
1. Producer connects to kafka-1
2. kafka-1 returns cluster metadata
3. Producer learns partition leaders
4. Producer connects directly to those leaders
```

Example:

```text
Producer
   |
   | bootstrap connection
   v
Broker 1
   |
   | metadata response
   v
Partition 0 leader = Broker 2
Partition 1 leader = Broker 3
Partition 2 leader = Broker 1
```

Then:

```text
Producer ──> Broker 2 for partition 0
Producer ──> Broker 3 for partition 1
Producer ──> Broker 1 for partition 2
```

The same concept applies to consumers.

---

# 7. Producer communication flow

Suppose the producer sends:

```text
Key: customer-10
Value: order-1001
```

Kafka client flow:

```text
Producer application
        |
        | 1. Calculate/select partition
        v
orders partition 2
        |
        | 2. Discover partition leader
        v
Broker 3
        |
        | 3. Send record to Broker 3
        v
Broker 3 stores record
```

If replication is enabled, the leader replicates it to follower brokers.

But the producer communicates primarily with the partition leader.

---

# 8. Consumer communication flow

A consumer group first interacts with a group coordinator.

```text
Consumer
    |
    | joins group
    v
Group coordinator broker
```

The coordinator manages:

- Group membership
- Partition assignment
- Rebalances
- Offset commits

After assignment, the consumer fetches records directly from the relevant partition leaders.

```text
Consumer
    |
    ├── fetch partition 0 from Broker 1
    ├── fetch partition 1 from Broker 2
    └── fetch partition 2 from Broker 3
```

The coordinator does not proxy all record data.

It coordinates the group.

---

# 9. Kafka CLI tools are real Kafka clients

These commands:

```text
kafka-console-producer.sh
kafka-console-consumer.sh
```

are small client applications built using Kafka’s client libraries.

They behave conceptually like your application code.

For example, this CLI producer:

```bash
kafka-console-producer.sh \
  --bootstrap-server kafka-1:19092 \
  --topic orders
```

is conceptually similar to:

```csharp
var producer = new ProducerBuilder<string, string>(config).Build();

await producer.ProduceAsync(
    "orders",
    new Message<string, string>
    {
        Key = "customer-1",
        Value = "order-1"
    });
```

The CLI is simply easier for manual testing.

---

# 10. Where clients should run in a real system

A real design may look like:

```text
Kubernetes cluster
│
├── orders-api Pod
│   └── Kafka producer
│
├── payment-service Pod
│   └── Kafka consumer
│
├── notification-service Pod
│   └── Kafka consumer
│
└── Kafka cluster
    ├── Broker 1
    ├── Broker 2
    └── Broker 3
```

Or Kafka may run outside Kubernetes:

```text
Kubernetes
├── Producer Pods
└── Consumer Pods
        |
        v
External Kafka cluster
├── Broker 1
├── Broker 2
└── Broker 3
```

In both cases, producers and consumers are separate client workloads.

---

# 11. Why you normally should not run applications inside broker containers

Running application producers or consumers inside broker containers is not a production design.

Reasons:

- Broker and application lifecycles become coupled.
- Resource usage interferes with Kafka.
- Scaling becomes difficult.
- Failure boundaries become unclear.
- Upgrades become harder.
- Monitoring becomes confusing.
- It violates container separation principles.

Correct approach:

```text
One concern per workload
```

For example:

```text
kafka-1 container
└── Kafka broker only

orders-service container
└── Producer/consumer application

kafbat-ui container
└── Kafka UI
```

The CLI inside the broker container is acceptable only for:

- Learning
- Testing
- Troubleshooting
- Administration
- Temporary verification

---

# 12. Docker Compose alternative: separate client container

You could create a dedicated Kafka client container:

```yaml
services:
  kafka-client:
    image: apache/kafka:4.3.1
    entrypoint: ["sleep", "infinity"]
    networks:
      - kafka-net
```

Then execute CLI commands there:

```bash
docker compose exec kafka-client \
  /opt/kafka/bin/kafka-topics.sh \
  --bootstrap-server kafka-1:19092 \
  --list
```

Architecture:

```text
kafka-client container
├── console producer
├── console consumer
└── admin CLI tools

kafka-1 container
└── Kafka broker

kafka-2 container
└── Kafka broker

kafka-3 container
└── Kafka broker
```

This is logically cleaner, although not necessary for a small lab.

---

# 13. Internal versus external addresses

When the CLI runs inside the Docker network, it uses:

```text
kafka-1:19092
```

When a client runs on your laptop, it uses:

```text
localhost:29092
localhost:39092
localhost:49092
```

Example:

```text
Inside Docker:
kafka-1:19092

Outside Docker:
localhost:29092
```

This difference is caused by Docker networking, not by Kafka producer or consumer roles.

---

# 14. Final corrected mental model

Do not think:

```text
Kafka broker
├── Producer
└── Consumer
```

Think:

```text
Client applications
├── Producers
└── Consumers
        |
        v
Kafka cluster
├── Brokers
└── Controllers
```

The CLI lab only looked like this:

```text
Broker container
├── Broker process
└── Temporary CLI client process
```

because we reused the tools already installed in the broker image.

## Rules to memorise

```text
Broker
→ Stores records and serves Kafka requests

Producer
→ External client that writes records

Consumer
→ External client that reads records

Console producer/consumer
→ Test client applications

docker compose exec kafka-1
→ Runs a new process inside that container

--bootstrap-server
→ Initial contact point, not a permanent proxy

Producer and consumer
→ Connect directly to the correct partition leaders

CLI inside broker container
→ Convenient for labs, not a production architecture
```
