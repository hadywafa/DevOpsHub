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
