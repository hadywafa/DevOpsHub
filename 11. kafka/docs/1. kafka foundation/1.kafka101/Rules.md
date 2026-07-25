# Rules

> A partition can be assigned to **only one consumer within the same consumer group**, but the same partition can be consumed independently by consumers in **different consumer groups**.

## Rules to memorise

### 1. One partition → one consumer per consumer group

Inside a single consumer group, Kafka never assigns the same partition to two active consumers simultaneously.

Example:

```text
Topic: orders
Partitions: P0, P1, P2

Consumer Group: payment-service
Consumer A → P0, P1
Consumer B → P2
```

Consumer A and Consumer B will not both consume `P0`.

---

### 2. One consumer can consume multiple partitions

This is completely valid:

```text
3 partitions
1 consumer

Consumer A → P0, P1, P2
```

The consumer reads all three partitions.

---

### 3. More consumers than partitions means idle consumers

```text
3 partitions
5 consumers in the same group
```

Only three consumers can receive partitions:

```text
Consumer A → P0
Consumer B → P1
Consumer C → P2
Consumer D → idle
Consumer E → idle
```

So the maximum useful consumer parallelism in one group is:

```text
Maximum parallelism = number of partitions
```

---

### 4. Different consumer groups consume independently

```text
Topic: orders
Partitions: P0, P1, P2
```

```text
Group: payment-service
Consumer A → P0, P1, P2

Group: notification-service
Consumer B → P0, P1, P2

Group: analytics-service
Consumer C → P0, P1, P2
```

Each group receives its own logical copy of all messages.

This is not Kafka duplicating the stored message. Each group simply maintains its own offsets.

---

### 5. Ordering is guaranteed only inside one partition

Kafka guarantees:

```text
Message 1 → Message 2 → Message 3
```

only when those messages are in the same partition.

Kafka does not guarantee global ordering across different partitions.

```text
P0: A1, A2, A3
P1: B1, B2, B3
```

`A1 → A2 → A3` stays ordered, but Kafka does not guarantee whether `A2` is processed before or after `B1`.

---

### 6. Same key normally goes to the same partition

When messages use the same key:

```text
customerId = 123
```

Kafka's default key-based partitioning normally sends them to the same partition. This helps preserve order for that customer.

```text
Key 123 → P1
Key 123 → P1
Key 123 → P1
```

The number of partitions should not be changed casually when key-to-partition consistency matters, because changing the partition count can change the key mapping.

---

### 7. Offsets belong to the consumer group

Each consumer group tracks its own progress:

```text
payment-service offset:      150
notification-service offset: 120
analytics-service offset:     90
```

Therefore, one group can be ahead of or behind another group.

More precisely, Kafka stores an offset for each:

```text
Consumer Group + Topic + Partition
```

---

### 8. Consumer failure causes reassignment

When a consumer leaves or fails, Kafka reassigns its partitions to other consumers in the same group.

Before:

```text
Consumer A → P0
Consumer B → P1
```

If Consumer B fails:

```text
Consumer A → P0, P1
```

This reassignment is called a **rebalance**.

---

## Best sentence to memorise

> **Within one consumer group, each partition is assigned to at most one consumer. Across different consumer groups, the same partition can be consumed independently by each group.**

And the simplest formula:

```text
Useful consumers per group ≤ number of partitions
```

Example:

```text
6 partitions + 3 consumers = each consumer gets about 2 partitions
6 partitions + 6 consumers = each consumer gets 1 partition
6 partitions + 10 consumers = 6 active, 4 idle
```