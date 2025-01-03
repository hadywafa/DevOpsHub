# S3

## Object Storage

- S3 is a simple Key-Value object store.
- An Object is a file and any metadata that describes it.
- An S3 Bucket is a container for objects.
- Each object has a key (name) and a value which is the data stored.
- Each object cannot exceed `5TB in size`.
- Buckets and Objects are `private by default`, you need to grant permissions, so they become accessible.
- We use `HTTP requests` when dealing with S3.
- S3 supports HTTP and HTTPS endpoints.

## Data Consistency Model

- GET, PUT, UPDATE, and DELETE are HTTP requests (or HTTP Verbs or Method options) used when dealing with S3 buckets.
- S3 offers Read after write (immediate or strong) consistency for all requests of S3 objects.
- Updates to an object in S3 are atomic (we never get partial or corrupt data).
- To access an object in a bucket, the URI format is

  - `https://[bucket-name].s3.[Region].amazonaws.com/[key-name]`

## Region Selection

- Choosing an AWS region for your S3 buckets can be based on:

  - Optimizing latency,
  - Minimizing costs,
  - Addressing regulatory requirements.

- Objects stored in an AWS Region will never leave the Region unless the object owner explicitly transfers or replicates them to another Region

---

# S3 Tiered Storage Classes

![s3-storage-classes](images/s3-storage-classes.png)

## Notes

---

### Infrequent Access

- Both IA classes are for real-time instant access.
- One-Zone IA (single AZ) has the same durability as S3-IA.
- One-Zone IA has less availability and is less resilient compared to S3-IA.
- Minimum storage duration of 30 days.
- If an object is deleted before 30 days, a 30 days charge will apply.
- AWS charges for requests and for data retrieval (per GB).

### Archiving Classes

- All archive classes have eleven 9’s durability.
- S3 Glacier Instant Retrieval: for rarely accessed data that requires msec retrieval time.
  - Higher data access charges compared to S3-IA class.
- S3 Glacier Flexible Retrieval: Use for archives where data may need to be retrieved in minutes.
  - 90 days minimum storage charge.
- S3 Glacier Deep Archive: Use for archives that rarely need to be accessed.
  - 180 days minimum storage charge.
- Both Glacier Flexible Retrieval and Glacier Deep Archive are for cold storage (data access is asynchronous)

#### Glacier Flexible Retrieval & Glacier Deep Archive retrieval options

- Are designed to sustain data loss in two facilities (They replicate data in 3+ AZs).
- Glacier archives are visible and available only through AWS S3 dashboard.
- To guarantee access for expedited retrieval, customers can purchase provisioned `retrieval capacity`.
- Deep_Archive & Bulk Retrieval is the cheapest of all S3 classes

| **Storage Class**                 | **Expedited**    | **Standard**    | **Bulk**        |
| --------------------------------- | ---------------- | --------------- | --------------- |
| **S3 Glacier Flexible Retrieval** | 1-5 minutes (\$) | 3-5 hours       | 5-12 hours      |
| **S3 Glacier Deep Archive**       | N/A              | Within 12 hours | Within 48 hours |

#### Glacier Deep Archive –Archives and Vaults

- An archive is the base storage unit in Glacier (40TB max size).
- An archive can be any data such as a file, a photo, or a document.

---

- A vault is a container to store archives.
- A vault is confined to an AWS region.
- A vault can store an unlimited number of archives.
- Maximum 1000 vaults per AWS region. We can get archives uploaded to vaults using:
- CLI, SDKs (not the AWS console).

### Intelligent Tiering

- S3 Intelligent-Tiering is a storage class intended to optimize storage costs.
- Use it when data access pattern is unknown, changing, or unpredictable (data lakes, data analytics, and new applications).
- It monitors data access patterns and automatically moves data (at the object level) to the most cost effective S3 access tier.
- There is no retrieval fees for Intelligent-Tiering.
- AWS charges a small monthly monitoring fee.
- If the data is accessed again, it gets moved back to the Frequent Access Tier.

---

- Activating the Archive Access Tier will bypass the Archive Instant Access Tier.
  - It is like S3 Glacier Flexible Retrieval storage class.
- Deep Archive Access Tier, when enabled, objects not accessed for 180 days (configurable to 730 days) will be moved in this class.
  - It like S3 Glacier Deep Archive tier.
- For both Archive and Deep Archive access tiers retrieval time is required.

![s3-intelligent-lifecycle-if-cold-storage-not-enabled](images/s3-intelligent-lifecycle-if-cold-storage-not-enabled.png)
![s3-intelligent-lifecycle-if-cold-storage-enabled](images/s3-intelligent-lifecycle-if-cold-storage-enabled.png)
