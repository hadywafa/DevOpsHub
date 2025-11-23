# Secrets Store CSI Driver

> `Mounts volumes with secrets directly into pods`  
> `No secret is stored in K8s.`  
> `No secret is stored in etcd.`  
> `No secret is written to the container filesystem.`

## 📚 Docs

- [Secrets Store CSI Driver](https://secrets-store-csi-driver.sigs.k8s.io/introduction)
- [Secrets Store CSI Driver](https://github.com/kubernetes-sigs/secrets-store-csi-driver)
- [Manage Secrets on AWS EKS using Secrets Store CSI Driver](devopscube.com/secrets-store-csi-dirver-eks/)

## 📹 Architecture

![1763882267987](image/secrets-store-csi-driver/1763882267987.png)

## ❓ Why it is the Best Approach

there is different approch, let explain bottelneck of each approch

### 📌 1. k8s secrets

> no encryption at rest as it is base64
> chaos, as no place to centralize the secrets

---

### 📌 2. encrypt k8s secret at rest in etcd with encryption provider

> bad rbac for user can read the secrets easly
> chaos, as no place to centralize the secrets

---

### 📌 3. sealed secrets

> sealed secrets will map o k8s plain secret which is base64 encoded

---

### 📌 4. external secrets

> sealed secrets will map o k8s plain secret which is base64 encoded

---

### 📌 5. application get its secrets via api

> Broke the Principle of:
>
> - DRY
> - Single Responsibility

---

### 📌 6. init container get the secrets annd mount to main container

> no update the secret

---

### 📌 7. sidecar get the secrets and mount to main container

> end up with alot of containers that consume resources and needes to be managed.
