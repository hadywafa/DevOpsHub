# StorageClass in Kubernetes

1. **Definition**:
   - A StorageClass provides a way for administrators to describe the “classes” of storage they offer.
   - Different classes might map to quality-of-service levels, backup policies, or other arbitrary policies determined by the cluster administrators.

2. **Provisioners**:
   - Provisioners are plugins that interface with various storage backends to provision the actual storage. Kubernetes supports several built-in provisioners for cloud providers like AWS, Google Cloud, and Azure.
   - Common provisioners include:
     - `kubernetes.io/aws-ebs` for AWS Elastic Block Store.
     - `kubernetes.io/gce-pd` for Google Compute Engine Persistent Disk.
     - `kubernetes.io/azure-disk` for Azure Managed Disks.
     - `kubernetes.io/nfs` for NFS storage.

3. **Parameters**:
   - StorageClasses can specify parameters that are passed to the provisioner to control the storage provisioned.
   - Parameters may include disk type, IOPS, replication settings, etc., depending on the storage backend.

## How Dynamic Provisioning Works

1. **StorageClass Definition**:
   - Administrators define StorageClasses that specify the provisioner and parameters needed to create PVs.
   - Example for AWS:

     ```yaml
     apiVersion: storage.k8s.io/v1
     kind: StorageClass
     metadata:
       name: standard
     provisioner: kubernetes.io/aws-ebs
     parameters:
       type: gp2
       zones: us-east-1a, us-east-1b
     ```

2. **PVC Creation**:
   - Users create Persistent Volume Claims (PVCs) that specify the desired StorageClass.
   - When a PVC requests a StorageClass, Kubernetes uses the provisioner in the StorageClass to dynamically create a PV.
   - Example PVC:

     ```yaml
     apiVersion: v1
     kind: PersistentVolumeClaim
     metadata:
       name: pvc-dynamic
     spec:
       accessModes:
         - ReadWriteOnce
       resources:
         requests:
           storage: 20Gi
       storageClassName: standard
     ```

3. **Provisioning Process**:
   - Kubernetes detects the PVC and references the specified StorageClass.
   - The provisioner specified in the StorageClass (e.g., `kubernetes.io/aws-ebs`) interacts with the cloud provider’s API to create the storage volume (e.g., an EBS volume in AWS).
   - Once the volume is created, a Persistent Volume (PV) is dynamically generated and bound to the PVC.

4. **PV Usage**:
   - The dynamically provisioned PV is then used by pods, just like statically provisioned PVs.
   - Pods reference the PVC, which is bound to the dynamically created PV, and mount the storage as specified.

## Benefits

- **Automation**: Simplifies storage management by automating the provisioning process.
- **Scalability**: Easily scales with the application’s storage needs without manual intervention.
- **Flexibility**: Different StorageClasses can be defined for various performance and capacity requirements.
- **Integration**: Seamless integration with cloud provider APIs for efficient resource management.

## Built-in Provisioners

- `kubernetes.io/aws-ebs`: AWS Elastic Block Store.
- `kubernetes.io/gce-pd`: Google Compute Engine Persistent Disk.
- `kubernetes.io/azure-disk`: Azure Managed Disks.
- `kubernetes.io/nfs`: NFS storage.

## Example Workflow

1. **Define a StorageClass**:

   ```yaml
   apiVersion: storage.k8s.io/v1
   kind: StorageClass
   metadata:
     name: fast
   provisioner: kubernetes.io/aws-ebs
   parameters:
     type: io1
     iopsPerGB: "10"
     fsType: ext4
   ```

2. **Create a PVC with the StorageClass**:

   ```yaml
   apiVersion: v1
   kind: PersistentVolumeClaim
   metadata:
     name: fast-storage
   spec:
     accessModes:
       - ReadWriteOnce
     resources:
       requests:
         storage: 50Gi
     storageClassName: fast
   ```

3. **Kubernetes Provisions Storage**:
   - The provisioner (`kubernetes.io/aws-ebs`) creates an EBS volume with the specified parameters (type `io1`, `10` IOPS per GB, formatted as `ext4`).
   - A PV is created and bound to the PVC `fast-storage`.

4. **Use the PVC in a Pod**:

   ```yaml
   apiVersion: v1
   kind: Pod
   metadata:
     name: app-pod
   spec:
     containers:
     - name: app-container
       image: nginx
       volumeMounts:
       - mountPath: "/usr/share/nginx/html"
         name: storage
     volumes:
     - name: storage
       persistentVolumeClaim:
         claimName: fast-storage
   ```

## AWS EBS StorageClass Examples

### Prerequisites

1. **IAM Role and Policy**:
   - Create an IAM role with necessary permissions for managing EBS volumes.
   - Attach this role to your Kubernetes nodes.

#### IAM Policy Example

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:AttachVolume",
        "ec2:CreateSnapshot",
        "ec2:CreateTags",
        "ec2:CreateVolume",
        "ec2:DeleteSnapshot",
        "ec2:DeleteVolume",
        "ec2:DescribeInstances",
        "ec2:DescribeSnapshots",
        "ec2:DescribeVolumes",
        "ec2:DetachVolume"
      ],
      "Resource": "*"
    }
  ]
}
```

### Step-by-Step Configuration

1. **IAM Role Assignment**:
   - Attach the IAM role to your EC2 instances running Kubernetes nodes.
   - Use the AWS Management Console or AWS CLI to associate the IAM role with your instances.

2. **Kubernetes Cloud Provider Configuration**:
   - Ensure that the Kubernetes cluster is configured to use the AWS cloud provider. This typically involves setting the `--cloud-provider=aws` flag in the kube-controller-manager and kubelet.
   - You might also need to set environment variables or configuration files with AWS credentials if not using IAM roles.

#### Example Configuration for kube-controller-manager

Add the following flags to the kube-controller-manager manifest:

```yaml
- --cloud-provider=aws
- --cloud-config=/etc/kubernetes/cloud-config
```

Ensure the `cloud-config` file has the necessary AWS credentials if not using IAM roles:

```ini
[Global]
Zone = us-east-1a
```

### Using the StorageClass

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: aws-ebs-sc
provisioner: kubernetes.io/aws-ebs
parameters:
  type: gp2
  zones: us-east-1a, us-east-1b
  fsType: ext4
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: aws-ebs-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 20Gi
  storageClassName: aws-ebs-sc
---
apiVersion: v1
kind: Pod
metadata:
  name: aws-ebs-pod
spec:
  containers:
  - name: aws-ebs-container
    image: nginx
    volumeMounts:
    - mountPath: "/usr/share/nginx/html"
      name: aws-ebs-storage
  volumes:
  - name: aws-ebs-storage
    persistentVolumeClaim:
      claimName: aws-ebs-pvc
```

---

## NFS StorageClass Examples

### Prerequisites

1. **NFS Server Setup**:
   - Set up an NFS server and export a directory with the appropriate permissions.

#### Example NFS Server Export Configuration

On the NFS server, edit the `/etc/exports` file to add an export:

```plaintext
/mnt/nfs 192.168.1.0/24(rw,sync,no_root_squash)
```

Apply the export configuration:

```bash
exportfs -a
```

2. **NFS Client Setup**:
   - Ensure the NFS client packages are installed on all Kubernetes nodes.

#### Example NFS Client Installation

For Debian/Ubuntu:

```bash
sudo apt-get install nfs-common
```

For RHEL/CentOS:

```bash
sudo yum install nfs-utils
```

### Using the StorageClass

1. **Deploy a Custom NFS Provisioner**: Deploy an NFS provisioner in your Kubernetes cluster to manage NFS PVs dynamically.

#### Example NFS Provisioner Deployment

Use an NFS provisioner like `nfs-subdir-external-provisioner`:

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: nfs-provisioner
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nfs-client-provisioner
  namespace: nfs-provisioner
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nfs-client-provisioner
  template:
    metadata:
      labels:
        app: nfs-client-provisioner
    spec:
      containers:
      - name: nfs-client-provisioner
        image: quay.io/external_storage/nfs-client-provisioner:latest
        volumeMounts:
        - name: nfs-client-root
          mountPath: /persistentvolumes
        env:
        - name: PROVISIONER_NAME
          value: example.com/nfs
        - name: NFS_SERVER
          value: 192.168.1.100
        - name: NFS_PATH
          value: /mnt/nfs
      volumes:
      - name: nfs-client-root
        nfs:
          server: 192.168.1.100
          path: /mnt/nfs
---
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: nfs-sc
provisioner: example.com/nfs
parameters:
  archiveOnDelete: "false"
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: nfs-pvc
spec:
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 50Gi
  storageClassName: nfs-sc
---
apiVersion: v1
kind: Pod
metadata:
  name: nfs-pod
spec:
  containers:
  - name: nfs-container
    image: nginx
    volumeMounts:
    - mountPath: "/usr/share/nginx/html"
      name: nfs-storage
  volumes:
  - name: nfs-storage
    persistentVolumeClaim:
      claimName: nfs-pvc
```

---

## Local Disk StorageClass for On-Premises Server Examples

### Prerequisites

1. **Local Disk Setup**:
   - Ensure that the local disk storage is available and mounted on the Kubernetes nodes.

#### Example Local Disk Mounting

On the Kubernetes node, mount the local storage:

```bash
sudo mkdir -p /mnt/local-storage
sudo mount /dev/sdX /mnt/local-storage
```

### Using the StorageClass

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: local-disk-sc
provisioner: kubernetes.io/no-provisioner
volumeBindingMode: WaitForFirstConsumer
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: local-disk-pv
spec:
  capacity:
    storage: 100Gi
  accessModes:
    - ReadWriteOnce
  local:
    path: /mnt/local-storage
  nodeAffinity:
    required:
      nodeSelectorTerms:
      - matchExpressions:
        - key: kubernetes.io/hostname
          operator: In
          values:
          - your-node-name
  storageClassName: local-disk-sc
  persistentVolumeReclaimPolicy: Retain
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: local-disk-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 100Gi
  storageClassName: local-disk-sc
---
apiVersion: v1
kind: Pod
metadata:
  name: local-disk-pod
spec:
  containers:
  - name: local-disk-container
    image: nginx
    volumeMounts:
    - mountPath: "/usr/share/nginx/html"
      name: local-disk-storage
  volumes:
  - name: local-disk-storage
    persistentVolumeClaim:
      claimName: local-disk-pvc
```

### Communication and Credentials

- **No External Credentials Needed**: Since this setup uses local disks, no external credentials are needed. The nodes already have access to the local storage paths specified in the PV.
- **Node Affinity**: Ensure that the PV specifies node affinity to bind the storage to the correct node where the local disk is available.
