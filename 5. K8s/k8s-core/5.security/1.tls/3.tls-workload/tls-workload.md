# 🔐 mTLS in Kubernetes with Istio — Full Flow in Your Style

> Goal:
> **Encrypt all pod-to-pod traffic + give each service a strong identity + control who can call whom**, _without_ changing your app code.

We’ll go through:

1. 🧱 Concept: What is mTLS in Istio?
2. 🧠 Architecture: How Istio does mTLS under the hood
3. ⚙️ Enabling mTLS (mesh-wide, namespace, and per workload)
4. 🎯 Locking traffic using AuthorizationPolicy
5. 🔍 Verifying that mTLS is actually working
6. ⚠️ Common pitfalls (the “why is everything broken” section)

---

## 📖 What is mTLS in Istio?

Normal Kubernetes (no mesh):

- `frontend` → `backend` sends plain HTTP/TCP inside the cluster.
- Anyone who can reach the network can:

  - Sniff traffic
  - Impersonate services (no real identity)

With **Istio mTLS**:

- Each pod has a **sidecar (Envoy)**.
- All traffic between services **goes through Envoy**.
- Envoy ↔ Envoy communication uses **mutual TLS**:

  - Traffic is **encrypted**
  - Each side **authenticates** the other using certificates.
  - Each workload has a strong identity:
    `spiffe://cluster.local/ns/<namespace>/sa/<service-account>`

So it becomes:

```text
App A → Envoy A → 🔐 mTLS → Envoy B → App B
```

Your code still does:

```http
http://backend:8080
```

But wire-level traffic is **mTLS**, not plain.

---

## ⚙️ How Istio implements mTLS under the hood

### Components involved:

- **Istiod** = control plane + Certificate Authority (by default).
- **Envoy sidecar** = data plane proxy injected beside each pod.

### Flow when a pod starts:

1. Pod comes up in a namespace with `istio-injection=enabled`.
2. Sidecar container (Envoy) is injected.
3. Envoy connects to **Istiod** using bootstrap certs.
4. Istiod issues a **short-lived X.509 cert** (SPIFFE identity) to Envoy:

   - `spiffe://cluster.local/ns/my-namespace/sa/my-service-sa`

5. Envoy stores this cert + private key and uses it for:

   - Client auth (when calling others)
   - Server auth (when others call it)

### Flow when Service A calls Service B:

1. App A calls `http://service-b:8080`
2. iptables rules redirect traffic → Envoy A.
3. Envoy A looks at Istio config and decides:

   - “I must talk to service B over mTLS”

4. Envoy A opens a **TLS connection** to Envoy B:

   - Sends its client certificate (A’s identity)
   - Verifies B’s server certificate (B’s identity)

5. If both sides verify → secure mTLS tunnel
6. Inside that tunnel, HTTP/gRPC traffic flows.

Your app never sees TLS — sidecars handle everything.

---

## 🪜 Enabling mTLS — Step by Step

### 🔹 Step 0: Enable sidecar injection

For any namespace you want in the mesh:

```bash
kubectl label namespace my-app istio-injection=enabled
```

Then **restart pods** in that namespace so they get Envoy.

---

### 🔹 Step 1: Mesh-wide mTLS with PeerAuthentication

Istio uses `PeerAuthentication` to configure **how workloads expect incoming traffic**:

- `STRICT` → must be mTLS
- `PERMISSIVE` → accept both mTLS and plain
- `DISABLE` → plain only

#### ✅ Option A — Start safe with PERMISSIVE (good migration strategy)

```yaml
apiVersion: security.istio.io/v1beta1
kind: PeerAuthentication
metadata:
  name: default
  namespace: istio-system
spec:
  mtls:
    mode: PERMISSIVE
```

- Pods with sidecars:

  - Prefer mTLS for in-mesh traffic
  - Still accept plain traffic (from legacy/non-mesh clients).

#### ✅ Option B — Go full secure with STRICT (everything must be mTLS)

```yaml
apiVersion: security.istio.io/v1beta1
kind: PeerAuthentication
metadata:
  name: default
  namespace: istio-system
spec:
  mtls:
    mode: STRICT
```

- Now, for all workloads in the mesh:

  - Incoming traffic must be **mTLS**, not plain.
  - Non-mesh clients talking directly to pods will **fail**.

> 🧠 In practice:
> Many teams go: `DISABLE → PERMISSIVE → STRICT`
> as they gradually inject sidecars and migrate clients.

---

### 🔹 Step 2: Namespace-level mTLS (your “staging” / “prod” style)

You don’t have to do mesh-wide all at once.
You can control namespace by namespace.

Example: enable STRICT mTLS only in `payments` namespace:

```yaml
apiVersion: security.istio.io/v1beta1
kind: PeerAuthentication
metadata:
  name: payments-strict
  namespace: payments
spec:
  mtls:
    mode: STRICT
```

Now:

- Every workload in `payments` expects **mTLS** on inbound.
- Other namespaces can still be permissive or disabled.

---

### 🔹 Step 3: Workload-level mTLS (very similar to your Cilium style: selector)

Example: only `app=backend` in namespace `shop` should enforce mTLS:

```yaml
apiVersion: security.istio.io/v1beta1
kind: PeerAuthentication
metadata:
  name: backend-strict
  namespace: shop
spec:
  selector:
    matchLabels:
      app: backend
  mtls:
    mode: STRICT
```

- Only pods with `app=backend` require mTLS inbound.
- Other pods in `shop` use whatever other PeerAuthentication applies (namespace/global).

---

## 👮🏻 Using identities with AuthorizationPolicy (zero trust)

mTLS gives you **who you are** (identity).
`AuthorizationPolicy` uses that identity to decide **who can call whom**.

### Identity format (SPIFFE):

```text
spiffe://cluster.local/ns/<namespace>/sa/<service-account>
```

So if a pod uses service account `frontend-sa` in namespace `shop`, its identity is:

```text
cluster.local/ns/shop/sa/frontend-sa
```

(That’s what you put in `principals`.)

---

### 🔹 Example: only frontend → backend (same namespace)

Namespace: `shop`
Service accounts: `frontend-sa`, `backend-sa`

```yaml
apiVersion: security.istio.io/v1beta1
kind: AuthorizationPolicy
metadata:
  name: backend-ingress
  namespace: shop
spec:
  selector:
    matchLabels:
      app: backend # this policy applies to backend pods
  rules:
    - from:
        - source:
            principals:
              - "cluster.local/ns/shop/sa/frontend-sa"
```

Meaning:

- Target = all pods with `app=backend` in `shop`.
- Allowed source = **only workloads using `frontend-sa` in `shop`**.
- Everyone else → denied.

Now couple this with:

```yaml
PeerAuthentication (shop namespace) → STRICT mTLS
```

And you have:

- Encrypted traffic
- Strong identity
- AuthZ based on service accounts

---

### 🔹 Example: backend → db only, and nothing else

```yaml
apiVersion: security.istio.io/v1beta1
kind: AuthorizationPolicy
metadata:
  name: db-ingress
  namespace: shop
spec:
  selector:
    matchLabels:
      app: db
  rules:
    - from:
        - source:
            principals:
              - "cluster.local/ns/shop/sa/backend-sa"
```

Result:

- Only pods with identity `cluster.local/ns/shop/sa/backend-sa` can call `app=db`.
- frontend → db is blocked, even though they share namespace.

That’s clean zero-trust segmentation with mTLS identities.

---

## 🔍 Verifying that mTLS is actually working

### 🧪 Check TLS mode between services

Istio has a handy command:

```bash
istioctl authn tls-check <src-pod>.<ns> <dst-service>.<ns>.svc.cluster.local
```

Example:

```bash
istioctl authn tls-check frontend-5c8d96b68c-abcde.shop backend.shop.svc.cluster.local
```

You’ll get output like:

- `mTLS` ✅ (what you want)
- `plaintext` ❌ (no TLS)
- `TLS` (one-way TLS, usually external)

---

### 🔐 Inspect certificates on a pod’s sidecar

```bash
istioctl pc secret <pod-name>.<namespace>
```

You’ll see the issued cert:

- CN / SANs including:

  - `spiffe://cluster.local/ns/...`

---

### 👀 Use Kiali (if installed)

- Graph view shows **lock icons** between services when mTLS is on.
- You can visually see which services talk mTLS vs plaintext.

---

## ⚠️ Common Pitfalls (aka “why did everything break?”)

### ❌ 1. Enabling STRICT mTLS while some clients are **not in the mesh**

- If a pod doesn’t have a sidecar, it cannot speak Istio mTLS.
- STRICT means: “I only accept mTLS from Envoy clients.”
- So:

  - Non-injected workloads
  - External tools hitting ClusterIP directly
    will suddenly fail.

✅ Fix: start with `PERMISSIVE` during migration.

---

### ❌ 2. Forgetting service accounts when using `principals`

Your `AuthorizationPolicy` uses:

```yaml
principals:
  - cluster.local/ns/shop/sa/frontend-sa
```

But your Deployment:

```yaml
spec:
  serviceAccountName: another-name
```

Now the identity doesn’t match → everything denied.

✅ Fix: always align `serviceAccountName` with the identities in your AuthorizationPolicy.

---

### ❌ 3. Trying to mTLS external services directly

Istio mTLS is **for in-mesh workloads**.
For external APIs (e.g., Stripe, GitHub), you:

- Use **egress gateways** or **simple TLS origination** (client-side TLS)
- That’s _not_ the same as Istio internal SPIFFE mTLS.

---

### ❌ 4. Forgetting sidecar injection

- If namespace is not labeled `istio-injection=enabled`, or you did not re-deploy pods, there will be **no sidecar**.
- No sidecar == no mTLS.

---

## 🎯 Mini “end-to-end” example in your style

Let’s define a small “shop” app:

- Namespace: `shop`
- Workloads: `frontend` (sa `frontend-sa`), `backend` (sa `backend-sa`), `db` (sa `db-sa`)
- Requirements:

  - All service-to-service traffic is mTLS.
  - Only `frontend` → `backend`.
  - Only `backend` → `db`.

### 1️⃣ Enable injection

```bash
kubectl create namespace shop
kubectl label namespace shop istio-injection=enabled
```

Deploy your services with proper `serviceAccountName`s.

---

### 2️⃣ Enable STRICT mTLS in `shop`

```yaml
apiVersion: security.istio.io/v1beta1
kind: PeerAuthentication
metadata:
  name: shop-strict
  namespace: shop
spec:
  mtls:
    mode: STRICT
```

---

### 3️⃣ Authorization: frontend → backend only

```yaml
apiVersion: security.istio.io/v1beta1
kind: AuthorizationPolicy
metadata:
  name: backend-ingress
  namespace: shop
spec:
  selector:
    matchLabels:
      app: backend
  rules:
    - from:
        - source:
            principals:
              - "cluster.local/ns/shop/sa/frontend-sa"
```

---

### 4️⃣ Authorization: backend → db only

```yaml
apiVersion: security.istio.io/v1beta1
kind: AuthorizationPolicy
metadata:
  name: db-ingress
  namespace: shop
spec:
  selector:
    matchLabels:
      app: db
  rules:
    - from:
        - source:
            principals:
              - "cluster.local/ns/shop/sa/backend-sa"
```

Now you have:

- 🔐 All traffic between services = mTLS
- 👮 Identity-aware policies = who can call whom
- 🚫 Any other service: denied automatically
