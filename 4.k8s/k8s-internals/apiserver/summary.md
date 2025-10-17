# 🧠 **Kubernetes API Server — The Brain & Gatekeeper of the Cluster**

## 💡 **One-liner**

> **API Server = Gatekeeper + Router + Validator + Persistence Layer.**  
> Everything in Kubernetes passes through it → it **authenticates**, **authorizes**, **admits**, **stores to etcd**, and **notifies controllers** instantly.

---

## 🛣️ **Life of a Request (Happy Path)**

**kubectl → API Server → AAA → Storage → Notify!**

1. 🪪 **AuthN** — “Who are you?” (Certs, Tokens, OIDC, Webhook)
2. 🔐 **AuthZ** — “Are you allowed?” (RBAC, ABAC, Node, Webhook)
3. 🧩 **Admission** — Validate / mutate / deny (via controllers or webhooks)
4. 💾 **Storage** — Encoded in Protobuf → sent via gRPC → saved to **etcd**
5. 🔔 **Notify** — Controllers & clients get watch events instantly

🧠 **Mnemonic:** **A-A-A → S → N** → _Authenticate → Authorize → Admit → Store → Notify_

---

## 🧩 **Core Building Blocks**

<div align="center" style="background-color: #141a19ff;color: #a8a5a5ff; border-radius: 10px; border: 2px solid">

| Component                     | Description                                      |
| ----------------------------- | ------------------------------------------------ |
| **REST Handler & API Router** | Maps `/api` & `/apis` paths to resource handlers |
| **Authentication**            | Verifies identity (certs, tokens, OIDC)          |
| **Authorization**             | Checks permissions via **RBAC**, ABAC, etc.      |
| **Admission Chain**           | Mutating → Validating controllers/webhooks       |
| **Storage Interface**         | Encodes Protobuf, writes to etcd via `clientv3`  |
| **Watch Cache**               | Keeps hot data in RAM for fast list/watch        |

</div>

---

## ⚙️ **Request Flow Diagram**

<div align="center" style="background-color: #141a19ff;color: #a8a5a5ff; border-radius: 10px; border: 2px solid">

```mermaid
sequenceDiagram
  participant User
  participant API as API Server
  participant etcd
  participant Ctrl as Controller

  User->>API: POST /api/v1/pods
  API->>API: AuthN → AuthZ → Admission
  API->>etcd: PUT /registry/pods/ns1/pod1
  etcd-->>API: OK (rev=57)
  API-->>User: 201 Created
  API-->>Ctrl: Watch event (ADDED)
```

</div>

> 🧩 Every Pod/Deployment is **stored first**, then **controllers act** using **watch events**.

---

## 🗺️ **Read vs Write Paths**

<div align="center" style="background-color: #141a19ff;color: #a8a5a5ff; border-radius: 10px; border: 2px solid">

| Operation                   | Path                                              | Data Source      |
| --------------------------- | ------------------------------------------------- | ---------------- |
| **Writes (POST/PUT/PATCH)** | Client → API → AAA → etcd                         | Always hits etcd |
| **Reads (GET/List)**        | Client → API → **Watch Cache** → fallback to etcd | Usually cache    |

</div>

---

> ⚡ **Most reads** served from cache → minimal etcd load.  
> 💾 **Writes** always hit etcd for consistency.

---

## 🧱 **How Data Lives in etcd**

<div align="center" style="background-color: #141a19ff;color: #a8a5a5ff; border-radius: 10px; border: 2px solid">

```mermaid
graph LR
  subgraph etcd
    A[/registry/pods/ns1/pod1/] --> B[(Pod JSON / Protobuf)]
  end
```

</div>

---

> 🧩 Stored under `/registry/<resource>/<namespace>/<name>` with **linearizable consistency**.

---

## 🧬 **Object Lifecycle**

<div align="center" style="background-color: #141a19ff;color: #a8a5a5ff; border-radius: 10px; border: 2px solid">

```mermaid
graph LR
  A[Create Spec] --> B[Validate Schema]
  B --> C[Mutate Defaults]
  C --> D[Store in etcd]
  D --> E[Notify Watchers]
  E --> F[Controller Updates Status]
```

</div>

---

> **Spec** → Desired state (user input)  
> **Status** → Observed state (updated by controllers)

---

## 🔐 **Security Pipeline**

<div align="center" style="background-color: #141a19ff;color: #a8a5a5ff; border-radius: 10px; border: 2px solid">

```mermaid
graph LR
  A[Client] --> B[AuthN]
  B --> C[AuthZ]
  C --> D[Admission]
  D --> E[Storage]
  E --> F[Response]
```

</div>

---

> ❌ Drop anywhere in the chain = request denied  
> ✅ Pass all → safely persisted in etcd

---

## 🧰 **Extensibility**

- **CRDs (Custom Resource Definitions)** → add new resource types dynamically
- **API Aggregation** → plug external APIs (e.g. `metrics.k8s.io`)

> 🧩 Extend without touching core binaries.

---

## 📈 **Performance Memory Map**

<div align="center" style="background-color: #141a19ff;color: #a8a5a5ff; border-radius: 10px; border: 2px solid">

| ⚙️ Optimization          | 💡 Why it matters                       |
| ------------------------ | --------------------------------------- |
| **Watch Cache**          | Serves hot reads, reduces etcd pressure |
| **Protobuf encoding**    | Faster than JSON                        |
| **Chunked lists**        | Paginated large object lists            |
| **Throttling & timeout** | Protects API Server stability           |

</div>

---

## 🩺 **Observability Essentials**

- **Metrics** → `/metrics`

  - `apiserver_request_duration_seconds`
  - `apiserver_request_total`
  - `etcd_request_duration_seconds`

- **Health checks** → `/livez`, `/readyz`
- **Debug tools** → `/debug/pprof`

---

## 💥 **Common Failure Behaviors**

<div align="center" style="background-color: #141a19ff;color: #a8a5a5ff; border-radius: 10px; border: 2px solid">

| Scenario               | Behavior                                       |
| ---------------------- | ---------------------------------------------- |
| 🧱 **Etcd Down**       | Writes fail (503), cached reads may still work |
| ⏳ **Webhook Timeout** | Request rejected                               |
| ⚡ **API Overload**    | Throttling / backoff engaged                   |

</div>

---

## 🧠 **10-Second Recall**

> 🏗️ The **API Server** is the **single truth source** of Kubernetes.
> It **authenticates**, **authorizes**, **admits**, and **persists** all requests to **etcd**,
> while **streaming live events** to controllers via **watch cache**.
> Extensible (CRDs, aggregation), secure (TLS, AuthN/Z), and observable (metrics, health endpoints).

---

## 🖼️ **Visual Mind Map**

<div align="center" style="background-color: #141a19ff;color: #a8a5a5ff; border-radius: 10px; border: 2px solid">

```mermaid
graph TD
  subgraph API Server
    A[REST Handler]
    B[AuthN]
    C[AuthZ]
    D[Admission Chain]
    E[Storage Interface]
    F[Watch Cache]
  end
  G[(etcd)]
  H[Clients / Controllers]
  H-->A
  A-->B-->C-->D-->E-->G
  G-->F
  F-->H
```

</div>

---

> 🧩 **All requests** → **A-A-A → S → N** →  
> Checked, stored, and streamed back to the cluster’s brains.
