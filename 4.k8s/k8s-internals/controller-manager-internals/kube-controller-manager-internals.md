# 🧠 Kubernetes Controller Manager — Real Internal Mechanics (Full Practical View)

## 📖 **What Exactly Is It?**

The **Kubernetes Controller Manager** is a **separate process** — not part of the API Server.

- Binary name: `kube-controller-manager`
- Usually runs as a **static Pod** on the control plane node (like API server, scheduler, etcd)
- It connects to the **API Server over HTTPS (REST + Watch APIs)**
- It’s **stateless** — no local database; all state lives in etcd (via API Server)

📍 Location on a typical cluster:

```ini
/etc/kubernetes/manifests/kube-controller-manager.yaml
```

It uses flags like:

```ini
--kubeconfig=/etc/kubernetes/controller-manager.conf
--leader-elect=true
```

✅ So yes — it’s a **standalone application**, not embedded in the API Server.

---

## 🔁 **Lifecycle Overview** (How It Starts and Works)

Here’s the **real controller-manager lifecycle**, simplified step by step:

<div align="center" style="background-color: #255560ff; border-radius: 10px; border: 2px solid">

```mermaid
sequenceDiagram
  participant CM as Controller Manager
  participant API as API Server
  participant ET as etcd

  Note over CM: (1) Startup
  CM->>API: Authenticate via kubeconfig (certs)
  CM->>API: GET cluster info / version check

  Note over CM: (2) Controller registration
  CM->>CM: Initialize internal controllers (Node, ReplicaSet, etc.)

  API->>ET: Watch /registry/pods
  ET-->>API: Snapshot (rev=10)
  Note over ET: future changes streamed live
  ET-->>API: PUT podA rev=11
  ET-->>API: DELETE podB rev=12


  Note over CM,API: (3) Watch setup
  CM->>API: "WATCH /api/v1/pods?watch=true"
  API-->>CM: Stream of Pod events (ADDED/MODIFIED/DELETED)

  Note over CM: (4) Reconcile Loop
  CM->>CM: Detect difference between desired vs actual
  CM->>API: PATCH/POST/DELETE objects as needed

  Note over CM: (5) Repeat forever
```

</div>

### 🧩 Communication Protocol:

- Uses **HTTPS (REST + watch)** over port `6443`
- **Watch API** uses **HTTP long-lived streaming** — the API Server pushes events continuously
- The controller manager keeps an open connection and listens for changes

✅ So, it doesn’t poll; it **subscribes** to events.

---

## ⚙️ **Watch Mechanism** (Event Streaming)

Controllers subscribe to specific object kinds.
Example — Deployment Controller watches:

- `Deployments`
- `ReplicaSets`
- `Pods`

So internally:

```INI
GET /apis/apps/v1/deployments?watch=true
GET /apis/apps/v1/replicasets?watch=true
GET /api/v1/pods?watch=true
```

Then, the API Server streams JSON events like:

```json
{
  "type": "ADDED",
  "object": { "metadata": { "name": "nginx" }, "spec": {...} }
}
```

Controller Manager processes each event → puts into its work queue → runs reconciliation logic.

---

## 🧠 **Controller Manager Main Loop**

<div align="center" style="background-color: #255560ff; border-radius: 10px; border: 2px solid">

```mermaid
graph TD
  A[Start Controller Manager] --> B[Authenticate to API Server]
  B --> C[Start all controllers]
  C --> D[Each controller sends watch request for its resource type]
  D --> E[API Server streams events]
  E --> F[Controller compares desired vs actual state]
  F --> G[Controller updates resource via API call]
  G --> D
```

</div>

---

> ✅ **Each controller runs in its own Go routine (thread).**  
> ✅ **All communicate through the same API Server.**

---

## 💭 **Common Controllers** (and Their Behavior)

Now let’s visualize **how each common controller behaves internally** when it starts and operates.

---

### 📌 **1. Node Controller**

**Purpose:** Track Node heartbeats and mark them `NotReady` if unresponsive.

<div align="center" style="background-color: #255560ff; border-radius: 10px; border: 2px solid">

```mermaid
sequenceDiagram
  participant K as Kubelet
  participant API
  participant CM as Node Controller

  Note over CM: Starts watching Nodes
  CM->>API: WATCH /api/v1/nodes?watch=true
  API-->>CM: Stream Node events
  K->>API: Updates NodeStatus every 10s

  CM->>CM: Check last heartbeat
  alt heartbeat missing > 40s
    CM->>API: PATCH Node: condition=NotReady
    CM->>API: Evict Pods from Node
  else Node healthy
    CM->>API: No action
  end
```

</div>

---

✅ Handles node lifecycle + pod eviction.

---

### 📌 **2. Deployment Controller**

**Purpose:** Manage ReplicaSets for versioned rollout.

<div align="center" style="background-color: #255560ff; border-radius: 10px; border: 2px solid">

```mermaid
sequenceDiagram
  participant U as User
  participant API
  participant DC as Deployment Controller
  participant RS as ReplicaSet Controller
  participant ET as etcd

  U->>API: Create Deployment (v1, replicas=3)
  DC->>API: WATCH /apis/apps/v1/deployments?watch=true
  API-->>DC: Event: Deployment created
  DC->>API: Create new ReplicaSet (v1)
  DC->>API: Set desired replicas=3
  RS->>API: Create Pods
  RS->>ET: Persist Pods
  Note over DC: watches rollout progress
  DC->>API: Update Deployment.Status (readyReplicas)
```

</div>

---

✅ Handles rolling updates and rollbacks.

---

### 📌 **3. Replication Controller**

**Purpose:** Ensure the number of Pods matches `spec.replicas`.

<div align="center" style="background-color: #255560ff; border-radius: 10px; border: 2px solid">

```mermaid
sequenceDiagram
  participant U as User
  participant API
  participant CM as Replication Controller
  participant K as Kubelet

  U->>API: POST RC (replicas=3)
  CM->>API: WATCH /api/v1/replicationcontrollers?watch=true
  API-->>CM: Event (ADDED)
  CM->>API: List Pods with same label selector
  CM->>CM: Compare desired(3) vs actual(n)
  alt less than desired
    CM->>API: Create new Pods
  else more than desired
    CM->>API: Delete extra Pods
  end
  API->>K: Schedule & start Pods
```

</div>

---

✅ Keeps replica count always accurate.

---

### 📌 **4. DaemonSet Controller**

**Purpose:** Run exactly one Pod per node.

<div align="center" style="background-color: #255560ff; border-radius: 10px; border: 2px solid">

```mermaid
sequenceDiagram
  participant API
  participant CM as DaemonSet Controller

  CM->>API: WATCH /apis/apps/v1/daemonsets?watch=true
  API-->>CM: Event (ADDED)
  CM->>API: List all Nodes
  CM->>CM: For each node, check if Pod exists
  alt Missing Pod
    CM->>API: Create Pod (nodeName=node1)
  end
  CM->>API: Watch for new Nodes
  API-->>CM: Node added
  CM->>API: Create Pod on new Node
```

</div>

---

✅ Auto-schedules Pods to all (or selected) nodes.

---

### 📌 **5. Job Controller**

**Purpose:** Run Pods until completion.

<div align="center" style="background-color: #255560ff; border-radius: 10px; border: 2px solid">

```mermaid
sequenceDiagram
  participant API
  participant CM as Job Controller
  participant K as Kubelet

  CM->>API: WATCH /apis/batch/v1/jobs?watch=true
  API-->>CM: Job created
  CM->>API: Create Pod(s) for the job
  K->>API: Pod phase updates (Running → Succeeded)
  CM->>CM: Count successful completions
  alt Completed = desired
    CM->>API: Mark Job "Completed"
  end
```

</div>

---

✅ Used for batch workloads.

---

### 📌 **6. Namespace Controller**

**Purpose:** Clean up resources when a namespace is deleted.

<div align="center" style="background-color: #255560ff; border-radius: 10px; border: 2px solid">

```mermaid
sequenceDiagram
  participant API
  participant CM as Namespace Controller

  CM->>API: WATCH /api/v1/namespaces?watch=true
  API-->>CM: Event (DELETED)
  CM->>API: List all objects with namespace=target
  CM->>API: Delete all resources
  CM->>API: Mark namespace as Terminated
```

</div>

---

✅ Ensures no orphaned resources remain.

---

### 📌 **7. ServiceAccount Controller**

**Purpose:** Create default ServiceAccount in every namespace.

<div align="center" style="background-color: #255560ff; border-radius: 10px; border: 2px solid">

```mermaid
sequenceDiagram
  participant API
  participant CM as SA Controller

  CM->>API: WATCH /api/v1/namespaces?watch=true
  API-->>CM: New namespace event
  CM->>API: Create "default" ServiceAccount
  CM->>API: Create secret token for it
```

</div>

---

✅ Ensures workloads can authenticate to the API server.

---

### 📌 **8. ResourceQuota Controller**

**Purpose:** Prevent users from exceeding CPU, memory, or object limits.

<div align="center" style="background-color: #255560ff; border-radius: 10px; border: 2px solid">

```mermaid
sequenceDiagram
  participant API
  participant CM as RQ Controller

  CM->>API: WATCH /api/v1/resourcequotas?watch=true
  API-->>CM: Event (ADDED)
  CM->>API: List resource usage in namespace
  CM->>CM: Calculate remaining quota
  CM->>API: Update status (used vs hard limits)
  Note over CM: Rejects new resources that exceed limit
```

</div>

---

✅ Keeps per-namespace resource usage within limits.

---

## 🏁 **Summary** of Event Flow

All controllers share this **core flow**:

<div align="center" style="background-color: #255560ff; border-radius: 10px; border: 2px solid">

```mermaid
graph LR
  A[Controller Manager] -->|Watch request| B[API Server]
  B -->|Stream JSON events| A
  A --> C[Compare desired vs actual state]
  C -->|PATCH/POST/DELETE| B
  B --> D["etcd (persist state)"]
```

</div>

---

> ✅ Communication protocol: **HTTPS + JSON streaming**  
> ✅ Event-driven — **not polling**  
> ✅ Stateless — **safe to restart anytime**

---

## 🧠 **TL;DR**

<div align="center" style="background-color: #141a19ff;color: #a8a5a5ff; border-radius: 10px; border: 2px solid">

| Concept                     | Description                                                   |
| --------------------------- | ------------------------------------------------------------- |
| **Component Type**          | Separate process (not inside API Server)                      |
| **Connection**              | HTTPS REST + Watch stream to API Server                       |
| **Responsibilities**        | Run all built-in controllers                                  |
| **Core Loop**               | Watch → Compare → Update → Repeat                             |
| **Storage**                 | Uses API Server (which stores in etcd)                        |
| **Fault Tolerance**         | Stateless; safe to restart                                    |
| **Leader Election**         | Only one active in HA cluster                                 |
| **Communication Direction** | Always from controller → API Server (never direct to Kubelet) |

</div>

---

## 💎 **Visual Summary**

<div align="center" style="background-color: #255560ff; border-radius: 10px; border: 2px solid">

```mermaid
graph TD
  A[Controller Manager] -->|Watch / Stream| B[API Server]
  B -->|Read/Write State| C[etcd]
  A --> D[Many Controllers: Node, Deployment, Job...]
  D --> B
```

</div>

---

✅ **In plain English:**

> The Controller Manager is a standalone control-plane process that opens watch streams to the API Server for each resource it manages. Whenever something changes (like a Deployment, Node, or Job), it receives an event, checks what’s missing or wrong, and sends back API requests (create/update/delete) to make the cluster match the desired state.
