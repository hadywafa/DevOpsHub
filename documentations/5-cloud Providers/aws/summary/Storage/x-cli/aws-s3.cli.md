# AWS S3 CLI

Certainly! Below is a structured guide for commonly used Amazon S3 CLI commands. This includes creating buckets, uploading and downloading files, listing buckets and objects, setting permissions, and more.

## Explain

### 1. **Bucket Operations**

#### Create a Bucket

```sh
aws s3api create-bucket --bucket my-bucket --region us-west-2 --create-bucket-configuration LocationConstraint=us-west-2
```

#### List Buckets

```sh
aws s3api list-buckets
```

#### Delete a Bucket

```sh
aws s3api delete-bucket --bucket my-bucket
```

#### Get Bucket Policy

```sh
aws s3api get-bucket-policy --bucket my-bucket
```

#### Set Bucket Policy

```sh
aws s3api put-bucket-policy --bucket my-bucket --policy file://policy.json
```

#### Delete Bucket Policy

```sh
aws s3api delete-bucket-policy --bucket my-bucket
```

### 2. **Object Operations**

#### Upload a Single File

```sh
aws s3 cp localfile.txt s3://my-bucket/remote-file.txt
```

#### Upload Multiple Files (Sync)

```sh
aws s3 sync local-folder/ s3://my-bucket/remote-folder/
```

#### Download a Single File

```sh
aws s3 cp s3://my-bucket/remote-file.txt localfile.txt
```

#### Download Multiple Files (Sync)

```sh
aws s3 sync s3://my-bucket/remote-folder/ local-folder/
```

#### List Objects in a Bucket

```sh
aws s3 ls s3://my-bucket/
```

#### List Objects with Prefix

```sh
aws s3 ls s3://my-bucket/prefix/
```

#### Delete an Object

```sh
aws s3 rm s3://my-bucket/remote-file.txt
```

#### Delete Multiple Objects (Sync)

```sh
aws s3 rm s3://my-bucket/remote-folder/ --recursive
```

### 3. **Permissions and Access Control**

#### Make a Bucket Public

```sh
aws s3api put-bucket-acl --bucket my-bucket --acl public-read
```

#### Make an Object Public

```sh
aws s3api put-object-acl --bucket my-bucket --key remote-file.txt --acl public-read
```

### 4. **Versioning**

#### Enable Versioning

```sh
aws s3api put-bucket-versioning --bucket my-bucket --versioning-configuration Status=Enabled
```

#### Suspend Versioning

```sh
aws s3api put-bucket-versioning --bucket my-bucket --versioning-configuration Status=Suspended
```

#### List Object Versions

```sh
aws s3api list-object-versions --bucket my-bucket
```

### 5. **Lifecycle Management**

#### Put Lifecycle Configuration

Save the lifecycle configuration in a file (e.g., `lifecycle.json`):

```json
{
    "Rules": [
        {
            "ID": "Move to Glacier",
            "Status": "Enabled",
            "Prefix": "",
            "Transitions": [
                {
                    "Days": 30,
                    "StorageClass": "GLACIER"
                }
            ]
        }
    ]
}
```

Apply the lifecycle configuration:

```sh
aws s3api put-bucket-lifecycle-configuration --bucket my-bucket --lifecycle-configuration file://lifecycle.json
```

#### Get Lifecycle Configuration

```sh
aws s3api get-bucket-lifecycle-configuration --bucket my-bucket
```

#### Delete Lifecycle Configuration

```sh
aws s3api delete-bucket-lifecycle --bucket my-bucket
```

### 6. **Cross-Origin Resource Sharing (CORS)**

#### Put CORS Configuration

Save the CORS configuration in a file (e.g., `cors.json`):

```json
{
    "CORSRules": [
        {
            "AllowedHeaders": ["Authorization"],
            "AllowedMethods": ["GET", "POST"],
            "AllowedOrigins": ["*"],
            "ExposeHeaders": ["x-amz-server-side-encryption"],
            "MaxAgeSeconds": 3000
        }
    ]
}
```

Apply the CORS configuration:

```sh
aws s3api put-bucket-cors --bucket my-bucket --cors-configuration file://cors.json
```

#### Get CORS Configuration

```sh
aws s3api get-bucket-cors --bucket my-bucket
```

#### Delete CORS Configuration

```sh
aws s3api delete-bucket-cors --bucket my-bucket
```

### 7. **Website Configuration**

#### Put Website Configuration

Save the website configuration in a file (e.g., `website.json`):

```json
{
    "IndexDocument": {
        "Suffix": "index.html"
    },
    "ErrorDocument": {
        "Key": "error.html"
    }
}
```

Apply the website configuration:

```sh
aws s3api put-bucket-website --bucket my-bucket --website-configuration file://website.json
```

#### Get Website Configuration

```sh
aws s3api get-bucket-website --bucket my-bucket
```

#### Delete Website Configuration

```sh
aws s3api delete-bucket-website --bucket my-bucket
```

### 8. **Encryption**

#### Server-Side Encryption with S3-Managed Keys (SSE-S3)

```sh
aws s3 cp localfile.txt s3://my-bucket/remote-file.txt --sse AES256
```

#### Server-Side Encryption with KMS-Managed Keys (SSE-KMS)

```sh
aws s3 cp localfile.txt s3://my-bucket/remote-file.txt --sse aws:kms --sse-kms-key-id alias/my-key
```

This structured guide provides a comprehensive overview of common S3 CLI commands you'll likely use. Always refer to the [official AWS CLI documentation](https://docs.aws.amazon.com/cli/latest/userguide/cli-services-s3.html) for more details and updates.
