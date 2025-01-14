# Mounting Volumes in Deployments

In Kubernetes, you can mount various types of volumes in a Deployment to provide storage for your Pods. Below is a comprehensive list of the different volume types supported in Kubernetes, along with examples of how to use them in a Deployment YAML file.

## 1. EmptyDir

An `EmptyDir` volume is created when a Pod is assigned to a node. It is initially empty and persists as long as the Pod is running.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: emptydir-deployment
spec:
  replicas: 1
  selector:
    matchLabels:
      app: emptydir
  template:
    metadata:
      labels:
        app: emptydir
    spec:
      containers:
        - name: my-container
          image: my-image:latest
          volumeMounts:
            - mountPath: /mnt/emptydir
              name: emptydir-volume
      volumes:
        - name: emptydir-volume
          emptyDir: {}
```

## 2. HostPath

A `HostPath` volume mounts a file or directory from the host node’s filesystem into your Pod.

```yaml
# This configuration allows the container to read from and write
# to the /data directory on the host node
# as if it were accessing /mnt/hostpath inside the container.

apiVersion: apps/v1
kind: Deployment
metadata:
  name: hostpath-deployment
spec:
  replicas: 1
  selector:
    matchLabels:
      app: hostpath
  template:
    metadata:
      labels:
        app: hostpath
    spec:
      containers:
        - name: my-container
          image: my-image:latest
          volumeMounts:
            - mountPath: /mnt/hostpath # This is the directory inside the container where the volume will be accessible.
              name: hostpath-volume
      volumes:
        - name: hostpath-volume
          hostPath:
            path: /data # Path on the host node
```

## 3. PersistentVolumeClaim

A `PersistentVolumeClaim` (PVC) allows you to request storage from a `PersistentVolume` (PV) that has been provisioned in your cluster.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: pvc-deployment
spec:
  replicas: 1
  selector:
    matchLabels:
      app: pvc
  template:
    metadata:
      labels:
        app: pvc
    spec:
      containers:
        - name: my-container
          image: my-image:latest
          volumeMounts:
            - mountPath: /mnt/pvc
              name: pvc-volume
      volumes:
        - name: pvc-volume
          persistentVolumeClaim:
            claimName: my-pvc # The name of your PVC
```

## 4. ConfigMap

A `ConfigMap` allows you to inject configuration data into your Pods.

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: my-config
data:
  config-key: config-value
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: configmap-deployment
spec:
  replicas: 1
  selector:
    matchLabels:
      app: configmap
  template:
    metadata:
      labels:
        app: configmap
    spec:
      containers:
        - name: my-container
          image: my-image:latest
          volumeMounts:
            - mountPath: /mnt/config
              name: config-volume
      volumes:
        - name: config-volume
          configMap:
            name: my-config # The name of your ConfigMap
```

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: my-config
data:
  APP_ENV: production
  APP_DEBUG: "false"
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: configmap-env-deployment
spec:
  replicas: 1
  selector:
    matchLabels:
      app: configmap-env
  template:
    metadata:
      labels:
        app: configmap-env
    spec:
      containers:
        - name: my-container
          image: my-image:latest
          env:
            - name: APP_ENV
              valueFrom:
                configMapKeyRef:
                  name: my-config # Name of the ConfigMap
                  key: APP_ENV # Key in the ConfigMap
            - name: APP_DEBUG
              valueFrom:
                configMapKeyRef:
                  name: my-config # Name of the ConfigMap
                  key: APP_DEBUG # Key in the ConfigMap
```

## 5. Secret

A `Secret` is used to store sensitive information, such as passwords, OAuth tokens, and SSH keys.

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: my-secret
type: Opaque
data:
  secret-key: c2VjcmV0LXZhbHVl # Base64 encoded value

---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: secret-deployment
spec:
  replicas: 1
  selector:
    matchLabels:
      app: secret
  template:
    metadata:
      labels:
        app: secret
    spec:
      containers:
        - name: my-container
          image: my-image:latest
          volumeMounts:
            - mountPath: /mnt/secret
              name: secret-volume
      volumes:
        - name: secret-volume
          secret:
            secretName: my-secret # The name of your Secret
```

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: my-secret
type: Opaque
data:
  SECRET_USERNAME: c3VwZXJ1c2Vy # Base64 encoded value
  SECRET_PASSWORD: cGFzc3dvcmQ= # Base64 encoded value
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: secret-env-deployment
spec:
  replicas: 1
  selector:
    matchLabels:
      app: secret-env
  template:
    metadata:
      labels:
        app: secret-env
    spec:
      containers:
        - name: my-container
          image: my-image:latest
          env:
            - name: SECRET_USERNAME
              valueFrom:
                secretKeyRef:
                  name: my-secret # Name of the Secret
                  key: SECRET_USERNAME # Key in the Secret
            - name: SECRET_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: my-secret # Name of the Secret
                  key: SECRET_PASSWORD # Key in the Secret
```

## 6. NFS (Network File System)

An NFS volume allows you to mount a remote NFS share into your Pod.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nfs-deployment
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nfs
  template:
    metadata:
      labels:
        app: nfs
    spec:
      containers:
        - name: my-container
          image: my-image:latest
          volumeMounts:
            - mountPath: /mnt/nfs
              name: nfs-volume
      volumes:
        - name: nfs-volume
          nfs:
            server: nfs-server-ip # The IP of your NFS server
            path: /path/to/nfs/share # The path on the NFS server
```

## 7. Azure Disk

An Azure Disk volume allows you to use Azure managed disks as storage for your Pods.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: azuredisk-deployment
spec:
  replicas: 1
  selector:
    matchLabels:
      app: azuredisk
  template:
    metadata:
      labels:
        app: azuredisk
    spec:
      containers:
        - name: my-container
          image: my-image:latest
          volumeMounts:
            - mountPath: /mnt/azuredisk
              name: azuredisk-volume
      volumes:
        - name: azuredisk-volume
          azureDisk:
            diskName: my-disk # The name of the Azure Disk
            diskURI: /subscriptions/... # The URI of the Azure Disk
            kind: Managed
```

## 8. AWS EBS (Elastic Block Store)

An AWS EBS volume allows you to use Amazon EBS as storage for your Pods.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: awsebs-deployment
spec:
  replicas: 1
  selector:
    matchLabels:
      app: awsebs
  template:
    metadata:
      labels:
        app: awsebs
    spec:
      containers:
        - name: my-container
          image: my-image:latest
          volumeMounts:
            - mountPath: /mnt/awsebs
              name: awsebs-volume
      volumes:
        - name: awsebs-volume
          awsElasticBlockStore:
            volumeID: aws://volume-id # The EBS volume ID
            fsType: ext4
```
