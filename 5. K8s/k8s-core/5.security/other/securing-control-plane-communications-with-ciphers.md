# 🔐 Securing Kubernetes With Strong TLS Versions & Cipher Suites

_(CKS Exam – Simple, Straightforward Explanation)!_

Kubernetes control-plane components communicate using **mTLS** (mutual TLS).
This includes:

- kube-apiserver
- kube-controller-manager
- kube-scheduler
- kubelet
- etcd

TLS security is only as strong as:

1. The **TLS version** used
2. The **cipher suite** selected during handshake

The CKS exam tests your ability to **restrict** both of these.

---

## 🧠 Why Cipher Hardening Matters

Every TLS connection chooses a cipher using **negotiation**:

```ini
Client supports: [A, B, C, D]
Server supports: [C, D, E, F]

Result → D (strongest supported by both)
```

The danger:

- Old software supports **weak ciphers**
- Attackers already know how to break them
- If Kubernetes accepts weak ciphers, a vulnerable client may force a downgrade

So, Kubernetes lets you **force**:

- minimum TLS version
- allowed cipher suites

---

## 🔧 Where Cipher Hardening Applies

These Kubernetes components support TLS version/cipher restrictions:

- ✔ API Server
- ✔ Controller Manager
- ✔ Scheduler
- ✔ Kubelet
- ✔ etcd

---

## ⚙️ Relevant Flags (Important for CKS)

**API Server / Kubelet / Controller Manager / Scheduler!**

**Minimum TLS version:**

```ini
--tls-min-version=
    VersionTLS10
    VersionTLS11
    VersionTLS12
    VersionTLS13
```

**Allowed cipher suites:**

```ini
--tls-cipher-suites=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256,...
```

### **etcd**

```ini
--cipher-suites=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256,...
```

If you don’t specify these options →
**Kubernetes uses the default cipher list from Go's crypto library.**

---

## 🚨 Compatibility Warning (VERY IMPORTANT in CKS)

If you set:

```ini
--tls-min-version=VersionTLS13
```

Then:

- ❌ Many TLS 1.2 ciphers will not work
- ❌ If you accidentally configure an incompatible cipher →
  **API server will NOT start**

This is exactly what exam questions try to trick candidates with.

---

## 🎓 CKS Exam Example (Very Common Pattern)

### **Question:**

> Restrict communication between API server and etcd to use only
> `TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256`
> and enforce minimum TLS version 1.2 on API server.

### Step 1 — Edit API Server

File:

```ini
/etc/kubernetes/manifests/kube-apiserver.yaml
```

Add:

```yaml
- --tls-min-version=VersionTLS12
- --tls-cipher-suites=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256
```

### Step 2 — Edit etcd manifest

File:

```ini
/etc/kubernetes/manifests/etcd.yaml
```

Add:

```yaml
- --cipher-suites=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256
```

### Step 3 — Wait for Pods to Restart

Kubelet automatically re-creates static pods → takes 30–60 seconds.

---

## 🛠 If API Server Doesn’t Come Back Up

This is **expected** if cipher suites conflict.

### Troubleshooting (Exam Steps)

1. Check pod status:

   ```bash
   kubectl get pod -n kube-system
   ```

2. If API server is NOT running → use node’s Docker/CRICTL:

   ```bash
   crictl ps -a | grep apiserver
   crictl logs <container-id>
   ```

3. Look for errors like:

   ```ini
   invalid cipher suite
   cipher not compatible with TLS version
   ```

4. Fix manifest → remove or correct the cipher

---

## 🧠 Easy Memory Trick

KodeKloud-style:

> **TLS-min-version protects against old protocol attacks.** > **TLS-cipher-suites protects against weak algorithms.** > **Use same cipher on both ends.**

---

## ✔ Summary (Exam Version)

| Component  | Flag                  | Purpose                      |
| ---------- | --------------------- | ---------------------------- |
| API Server | `--tls-min-version`   | Enforce TLS version          |
|            | `--tls-cipher-suites` | Restrict to specific ciphers |
| etcd       | `--cipher-suites`     | Must match API server        |

Always ensure:

- API server ↔ etcd use **same cipher**
- cipher is compatible with chosen `tls-min-version`
