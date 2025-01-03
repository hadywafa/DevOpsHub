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

---

# S3 Encryption

- Encryption in-transit means, encrypting data as it moves.
- Encryption at rest means, encrypting data while it is stored.
- Encryption at rest can be client-side or S3 (server-side) encryption

## **S3 Object Encryption At Transit**

S3 Provides HTTP and HTTPS endpoints.

<div align="center" style="padding: 0 20px;">
  <img src="images/encryption-at-transit.png" alt="encryption-at-transit">
</div>

- For encryption in-transit, we must use the HTTPS endpoint provided by S3. This can be enforced in the bucket policy
- Objects do not have to be encrypted at the client side if we choose not to.

## **S3 Object Encryption At Rest**

<div align="center" style="padding: 0 20px;">
  <img src="images/encryption-at-rest-types.png" alt="encryption-at-rest-types">
</div>

- Encryption at rest can be client-side or S3 (server-side) encryption.
- In client-side Encryption, the client is responsible for encrypting/decrypting the data. S3 has nothing to do with the encryption/decryption process or keys.
- In server-side Encryption, S3 manages the encryption/decryption and optionally the keys.
- We have three SSE encryption choices under S3, they are SSE-S3, SSE-KMS, and SSE-C

## Client-Side Encryption At Rest (CSE)

<div align="center" style="padding: 0 20px;">
  <img src="images/cse.gif" alt="Client-Side Encryption (CSE)">
</div>

- The client is responsible for the entire encryption/decryption and keys. AWS is not part of the encryption/decryption process.
- Each object is encrypted at the client side before it is moved to S3.
- Objects are encrypted in-transit automatically.

## Server-Side Encryption At Rest (SSE)

- Encryption/Decryption is done by S3 before the object is stored to disks
- Server-Side Encryption does not encrypt the object metadata.
- Depending on who provides the encryption keys, there are three SSE types:
  - **SSE-S3**
  - **SSE-KMS**
  - **SSE-C**

### 1. **SSE-S3**

<div align="center" style="padding: 0 20px;">
  <img src="images/sse-s3.gif" alt="sse-s3">
</div>

- Encryption Using S3-Managed Encryption Keys
- Each object will be encrypted with a separate data key created and managed by S3.
- **The Least customer overhead:** the customer has nothing to do with key creation or rotation

### 2. **SSE-KMS**

<div align="center" style="padding: 0 20px;">
<h3>
  It uses the AWS S3 default KMS key or a customer created/managed KMS key in AWS KMS.
</h3>
  <img src="images/sse-kms.gif" alt="sse-s3">
</div>

- The KMS key used must be in the same regions as the S3 bucket.
- The KMS key used can be created in KMS or imported to KMS by the customer
- Each object will be encrypted with a separate data key.
- Audit trail is provided for the KMS key usage.
- SSE-KMS with customer managed keys is chargeable (KMS key charge , plus data key request charges)

#### ⚠️ Potential Issues

Given that each object is encrypted with a separate data key. If we are using SSE-KMS extensively, this will add a lot of request charges and
may reach the KMS API operations (requests) per second limit in the account. This can lead to throttling of the additional requests.

#### ✅ Solution using bucket key

<div align="center" style="padding: 0 20px;">
<h3>
An S3 bucket key can be created by AWS KMS then used to generate the data
keys at the bucket level. It reduces the cost and the load on KMS.
</h3>
  <img src="images/sse-kms-bucket-key.gif" alt="sse-s3">
</div>

### 3. **SSE-C**

<div align="center" style="padding: 0 20px;">
<h3>
Encryption and decryption are done by S3 using a key provided by the customer.
</h3>
  <img src="images/sse-c.gif" alt="sse-s3">
</div>

- The customer must supply the data key with each encryption/decryption request.
- HTTPS must be used in-transit to protect the customer provided data keys
- SSE-C can only be done through SDKs.

## Bucket Default Encryption

This is a `bucket level` configuration.

<div align="center" style="padding: 0 20px;">
  <img src="images/default-encryption.png" alt="default-encryption">
</div>

- When enabled, all new object uploads without encryption information will be encrypted using the default encryption.
- If the request includes encryption information, the default encryption is not used.
- Pre-existing unencrypted data in the bucket before enabling this feature will not be encrypted automatically.
- We can choose between SSE-S3 or SSE-KMS

- S3 Glacier `Automatically` encrypts data at rest using AES-256-bit symmetric keys maintained by AWS.
- It supports secure data transfer in-transit over Secure Sockets Layer (SSL)
