# 🚀 **What Is Kubernetes Dashboard (2025)?**

Kubernetes Dashboard is a **web UI** that lets you:

- See Pods, Deployments, Services
- View logs
- Edit YAML
- Watch events
- Check cluster health
- Manage namespaces, RBAC, and storage

  **🔥 Important update (2025):**

Starting from **Dashboard v7.0**, the project:

- ❌ **Removed YAML/manifest installation**
- ❌ **Removed the old single-container architecture**
- ✔️ **Requires Helm**
- ✔️ **Uses Kong Gateway (DB-less) internally**
- ✔️ **Runs as multiple containers (UI, API, Kong, scraper)**

You **must use Helm** to install it.

---

![1763147225182](image/k8s-dashboard-security/1763147225182.png)

---

## 🏗️ **How to Install Kubernetes Dashboard (v7.x)**

### 1. Add the official Helm repo

```bash
helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard/
helm repo update
```

### 2. Install Dashboard into its namespace

```bash
helm upgrade --install kubernetes-dashboard \
  kubernetes-dashboard/kubernetes-dashboard \
  --namespace kubernetes-dashboard \
  --create-namespace
```

This installs:

- Dashboard UI
- Dashboard API
- Metrics scraper
- Kong gateway (proxy for Dashboard)

**No more kubectl apply recommended.yaml!**

---

## 🔐 **How to Access the Dashboard**

The Dashboard is **not exposed publicly**.

To access it:

## Using Port-forward (simple)

```bash
kubectl -n kubernetes-dashboard \
  port-forward svc/kubernetes-dashboard-kong-proxy 8443:443
```

Now open:

```ini
https://localhost:8443
```

---

## 🔑 **How to Log In**

Dashboard supports three login methods.

---

## ✔️ **1. ServiceAccount Token (simple, recommended for tests)**

### Step 1 — Create a ServiceAccount

```bash
kubectl create sa dashboard-admin -n kubernetes-dashboard
```

### Step 2 — Bind admin rights (use only for testing)

```bash
kubectl create clusterrolebinding dashboard-admin-binding \
  --clusterrole=cluster-admin \
  --serviceaccount=kubernetes-dashboard:dashboard-admin
```

### Step 3 — Generate a login token

(Uses TokenRequest API → short-lived JWT)

```bash
kubectl -n kubernetes-dashboard create token dashboard-admin
```

Copy the token → paste into Dashboard login page.

---

## ✔️ **2. OIDC Login (recommended for production)**

You can integrate Dashboard with:

- Keycloak
- Azure AD
- Okta
- Google Workspace

Example values in Helm chart:

```yaml
oidc:
  enabled: true
  issuerUrl: "https://accounts.google.com"
  clientId: "kubernetes-dashboard"
```

OIDC = the **secure** method for real clusters.

---

## ✔️ **3. Client Certificate (via kubectl proxy)** _(😭 Not Working)_

If you run:

```bash
kubectl proxy
```

Then visit:

```ini
http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/http:kubernetes-dashboard-kong-proxy:/proxy/
```

Dashboard sees the identity from your **client certificate** (your kubeconfig user).

---

## 📦 **Enable Metrics (optional)**

To display CPU/memory usage:

```bash
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
```

---

## 🧑‍💻 **How to Use Kubernetes Dashboard**

Once logged in, you can:

### 🔹 View workloads

- Pods
- Deployments
- ReplicaSets
- StatefulSets
- DaemonSets

### 🔹 Inspect resources

- Logs
- Events
- YAML
- Terminal (exec into pods)

### 🔹 Manage configuration

- ConfigMaps
- Secrets
- PVCs
- Storage Classes

### 🔹 Cluster operations

- Nodes
- Namespaces
- RoleBindings & ClusterRoleBindings
- CRDs (if permissions allow)

---

## 🔒 **Security Notes (Very Important)**

- ❌ Never expose Dashboard with a public LoadBalancer
- ✔ Use OIDC or short-lived tokens
- ✔ Use HTTPS only
- ✔ Apply strict RBAC
- ✔ Don’t give cluster-admin unless required

Dashboard is very powerful — always secure it properly.

---

## 🎯 **Ultra-Short Summary**

| Area         | Dashboard v7.x Behavior                 |
| ------------ | --------------------------------------- |
| Installation | **Helm only**                           |
| Architecture | **Multi-container + Kong gateway**      |
| Access       | **Port-forward or Ingress**             |
| Login        | **OIDC**, **SA token**, **client cert** |
| Metrics      | Needs **Metrics Server**                |
| Security     | Never expose publicly                   |
