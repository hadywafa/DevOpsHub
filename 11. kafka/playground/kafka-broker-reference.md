# Kafka Broker Reference: Request/Response Paths, Storage, and Tiered Storage

Source diagrams: Confluent Developer ("Fetch Requests", "Response Added to Socket Send Buffer", "Kafka Physical Storage", "Records Accumulated Into Record Batches", "Record Batches Drained Into Produce Requests")

---

## 0. Foundation: Record → RecordBatch

Before anything is sent, the producer builds these structures client-side.

```
Record =>
  timestamp
  key
  value
  Headers
```

Records for the same partition accumulate into a `RecordBatch`:

```
RecordBatch =>
  ...
  attributes: int16
    bit 0~2:
      0: no compression
      1: gzip
      2: snappy
      3: lz4
      4: zstd
    ...
  ...
  records: [Records]
    Record 1
    Record 2
    ...
    Record n
  └── all of the above compressed together ──┘
```

Key point: **compression happens once, on the whole batch** — not per record. That's what the `attributes` bitfield (bits 0–2) records, so the broker and consumer know how to decompress it later.

---

## 1. Producer → Broker: the Produce Request

### 1.1 RecordBatch drains into a ProduceRequest

Two producer configs decide *when* a batch stops accepting new records and gets sent:

| Config | Meaning |
|---|---|
| `batch.size` | target max size of one partition's batch |
| `linger.ms` | max time to wait for more records before sending anyway |

Once triggered, the batch is wrapped into a `ProduceRequest`:

```
ProduceRequest => acks [topic_data]
  acks => INT16
  topic_data => topic [data]
    topic => STRING
    data => partition record_set
      partition => INT32
      record_set => BYTES     <- the compressed RecordBatch goes here
  topic_data => topic [data]   <- a request can carry MULTIPLE topics/partitions
    ...
```

Important: **one ProduceRequest can carry batches for several topic-partitions**, as long as they're all led by the broker being contacted. `record_set` is just the raw compressed bytes from step 0 — the broker doesn't unpack or interpret them at this stage.

### 1.2 The request's path into the broker

```
Kafka Producer Client (APP)
        │
        ▼
Socket Send Buffer (producer's OS)
        │
        ▼
    [ network ]
        │
        ▼
Socket Receive Buffer (broker's OS)
        │
        ▼
   Network Threads   ← reads bytes, parses the ProduceRequest
        │
        ▼
   Request Queue     ← in-memory, shared queue inside the broker JVM
        │
        ▼
    IO Threads        ← does the actual work:
        │                 - confirms this broker is leader for the partition
        │                 - validates the batch / CRC
        │                 - appends record_set to the log
        ▼
   Page Cache (RAM) ──→ Disk (flushed later by the OS)
        │
        ▼
Replicated to Other Kafka Brokers (followers pull via fetch)
```

If `acks=all`, the IO thread doesn't sit and wait for followers to catch up — it registers the request in **Purgatory** and moves on to the next request. Purgatory releases it once the ISR condition is satisfied (or it times out).

---

## 2. Broker → Producer: the Produce Response

This is the return path, and it's worth tracking separately because of one detail: **each network thread has its own Response Queue.**

```
IO Threads / Purgatory (once the produce is complete)
        │
        ▼
Response Queue (per network thread)   ← NOT one global queue — 
        │                                one per network thread, so a
        │                                response always comes back
        │                                through the same thread that
        │                                handled the original connection
        ▼
   Network Threads
        │
        ▼
Socket Send Buffer (broker's OS)
        │
        ▼
    [ network ]
        │
        ▼
Kafka Producer Client (APP)
```

Because the response queue is scoped per network thread (not shared cluster-wide, not even shared across all network threads on the same broker), responses for a given connection are naturally ordered without extra coordination.

---

## 3. Consumer → Broker: the Fetch Request

The consumer asks for records starting at a given offset, not for a specific business key.

```
Kafka Consumer Client (APP)
        │
        ▼
Socket Send Buffer (consumer's OS)
        │
        ▼
    [ network ]
        │
        ▼
Socket Receive Buffer (broker's OS)
        │
        ▼
   Network Threads
        │
        ▼
   Request Queue
        │
        ▼
    IO Threads   ← "contiguous fetch ranges are calculated" here:
        │           finds the right segment, checks the .index,
        │           and works out a contiguous byte range to return
        ▼
   ┌─────────────────────────┬───────────────────────────────┐
   │ Data available locally  │ Data NOT available locally    │
   ▼                         ▼                                │
Page Cache → Disk      Tiered Fetch Threads → Object Store    │
   │                         │                                │
   └───────────┬─────────────┘                                │
               ▼
     (if not enough data yet: wait in Purgatory (Map)
      until fetch.min.bytes / fetch.max.wait.ms condition met)
```

Purgatory here is the same mechanism as on the produce side — it's a map-like structure keyed by topic-partition, and it's what lets the IO thread stay free instead of blocking on "not enough data yet."

Relevant consumer-side configs:

| Config | Meaning |
|---|---|
| `fetch.min.bytes` | desired minimum data before the broker responds |
| `fetch.max.wait.ms` | max time broker will wait for that minimum |
| `max.partition.fetch.bytes` | cap per partition in one response |
| `fetch.max.bytes` | cap for the whole fetch response |

---

## 4. Broker → Consumer: the Fetch Response, and zero-copy

```
Response ready (from Page Cache/Disk or from Tiered Fetch Threads)
        │
        ▼
Response Queue (per network thread)
        │
        ▼
   Network Threads
        │
        ▼
Data is (zero) copied to the Socket Send Buffer
        │
        ▼
    [ network ]
        │
        ▼
Kafka Consumer Client (APP)
```

The callout "data is (zero) copied to the send buffer" refers to Kafka's **zero-copy** optimization: bytes move straight from Page Cache to the socket send buffer via a kernel mechanism like `sendfile`, without an extra trip through a Java heap buffer in the broker process. This is why Kafka can serve consumers at high throughput even though it's disk-backed — as long as the data is in Page Cache. (Note: this zero-copy path is bypassed when SSL/TLS is enabled, since encryption has to happen in user space.)

---

## 5. Kafka Physical Storage

Each topic-partition gets its own directory on disk:

```
/var/lib/kafka/data/account-deposits-1/
    00000000000047926734.log
    00000000000047926734.index
    ...
    00000000000052497535.log
    00000000000052497535.index
    ...
```

- The directory name = `<topic>-<partition>`.
- Each numbered file pair is one **segment**. The number is the segment's **base offset** — not the only offset in the file, just where it starts.
  - `.log` holds the actual RecordBatches.
  - `.index` is a **sparse** mapping from offset → approximate byte position in the `.log` file (not one entry per record).
  - `.timeindex` (not shown here but part of the same segment) maps timestamps to offsets.
- Only one segment per partition is "active" (currently being appended to). Older segments are closed; retention and compaction act on closed segments.
- Writes land in the **Page Cache** (RAM) first; the OS flushes to physical disk on its own schedule. Kafka intentionally leans on this instead of maintaining a separate large in-heap cache.

---

## 6. What the Object Store is (Tiered Storage)

The **Object Store** box in the Fetch Requests diagram represents Kafka's optional **Tiered Storage** feature — not something every cluster has enabled.

**Without tiered storage:** all retained data lives on the broker's local disk / PersistentVolume, for as long as retention settings say so.

**With tiered storage enabled:**

```
Active segment (being written)
        │  stored locally, always
        ▼
Segment rolls / closes
        │
        ▼
Copied to remote Object Store   ← e.g. S3-compatible storage, Azure Blob, etc.
        │
        ▼
May be deleted from local disk
        │  (governed by a separate *local* retention setting,
        │   shorter than total/remote retention)
        ▼
Still retained remotely, for the full retention period
```

**Why a separate thread pool (Tiered Fetch Threads)?**
When a consumer asks for an old offset that's no longer on local disk, the normal IO thread doesn't reach out to object storage itself — that would be a slow, unpredictable operation sitting on a thread meant for fast local work. Instead, the broker hands that request to dedicated **Tiered Fetch Threads**, which talk to the Object Store, retrieve the old segment data, and feed it back into the response path. This keeps slow remote reads isolated from the fast path serving normal, recent-offset consumers.

**Practical implication:** consumers reading recent data (the common case) are served from Page Cache/local disk and stay fast. Consumers replaying very old history may hit the remote tier and see higher latency — but that latency is contained to the Tiered Fetch Threads, not the main request-handling threads.

---

## Quick index — which section answers which question

| Question | Section |
|---|---|
| How does a produce request get built and sent? | §1 |
| How does the broker respond to a produce request? | §2 |
| How does a consumer ask for data? | §3 |
| How does that data get back to the consumer efficiently? | §4 |
| Where do records actually live on disk? | §5 |
| What is the "Object Store" box, and why a separate thread pool for it? | §6 |
