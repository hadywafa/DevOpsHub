# Kinesis Data Streams

Kinesis data streams is a massively scalable and durable real-time data streaming service.

- It can collect gigabytes of data per second from 100,000s of sources.
- Data sources can include website click streams, database event streams, financial transactions, social media feeds, IT logs, and location tracking events.
- Use Kinesis data streams to ingest large data volumes in real time and make the data available, in milliseconds, for consumption by one or more Kinesis applications in parallel.
- These applications use Kinesis Client Library (KCL) and can run on Amazon EC2 instances.
- The processed data records can be used in different applications (dashboards, generate alerts, etc.)
- Data is stored in a stream for 24 hours by default, and up to 365 days.

## Availability, Durability, Use Cases & Encryption

Kinesis Data Streams synchronously replicates data across three AZs for high availability and data durability.

**Use cases include:**

- Accelerating log and data feed intakes.
- Real time metric and reporting analytics.
- Complex stream processing.

Kinesis data streams can encrypt data into the stream using SSE and KMS keys.

## Records, Shards, and Partition Keys

- A Kinesis stream is a set of shards using which producers put records in a Kinesis stream.
- Shards are billed in shard hours.
- Each record has a partition key specified by the producer, and a sequence number specified by Kinesis.
- The Amazon Kinesis Client Library (KCL) delivers all records for a given partition key to the same record processor or consumer.
- A shard can take up to 1MB/sec input (writes by producers) and up to 2MB/sec output (reads by consumers).
- If a shard gets more than 1000 PutRecord requests per sec, it will throttle and return an exception error.

## Re-sharding & Consumer Read Throughput

Kinesis data streams support re-sharding a stream.

- A shard can be split into two shards.
- We can merge two shards into one.
- As the number of shards increases, stream throughput increases, and cost increases too.

## Writing to a Kinesis Data Streams (KDSs)

We can write to a Kinesis Data Stream using:

- Amazon Kinesis Producer Library (KPL).
- Amazon KDS APIs using SDKs.
- Kinesis Agent.

## Capacity Modes

**On-demand mode:**

- Capacity planning (number of shards) is not required.
- Kinesis Data Streams automatically manages the shards in order to provide the necessary throughput.
- Pay per GB of data written and read from the stream.

**Provisioned mode:**

- You must specify the number of shards for the data stream.
- The total capacity of a data stream is the sum of the capacities of its shards.
- We can increase or decrease the number of shards in a data stream as needed.

We can switch between capacity modes after creating the stream.
