# 🫙 **ETCD Internals**

## 🏗️ 1. What is etcd?

**etcd** is a **distributed, strongly consistent key-value store** written in Go, used by Kubernetes (and others) to store cluster state.

Think of it as:

> “A highly reliable, memory of truth for your cluster — powered by consensus and careful persistence.”

💡 In Kubernetes, _every Pod, Node, ConfigMap, Secret, or Deployment_ you create lives inside etcd.

---

## ⚙️ 2. High-Level Architecture

```mermaid
graph TD
  A[Kubernetes API Server] -->|gRPC requests| B[etcd leader]
  B --> C1[etcd follower 1]
  B --> C2[etcd follower 2]
  B --> D[Write-Ahead Log (WAL)]
  B --> E[B+Tree Storage]
  B --> F[Watcher Engine]
```

| Component                    | Purpose                                               |
| ---------------------------- | ----------------------------------------------------- |
| **etcd cluster (3–5 nodes)** | Provides fault-tolerant replicated key-value store    |
| **Raft protocol**            | Ensures strong consistency via leader-based consensus |
| **WAL (Write-Ahead Log)**    | Guarantees durability                                 |
| **B+Tree Storage**           | Keeps actual key-value pairs on disk                  |
| **Watcher Engine**           | Streams real-time updates to clients                  |

---

## 🧩 3. The Raft Consensus Core

Etcd’s heart is the **Raft algorithm** — a simpler alternative to Paxos.
It ensures:
✅ A single authoritative leader
✅ Consistent replication
✅ Automatic failover
✅ Linearizable writes

---

### 🔁 3.1 The Three Roles

| Role          | Description                                         |
| ------------- | --------------------------------------------------- |
| **Leader**    | Handles all writes; coordinates followers           |
| **Follower**  | Replicates entries, responds to leader’s heartbeats |
| **Candidate** | Temporary role during elections                     |

---

### 🧭 3.2 Leader Election — How a Cluster Bootstraps Itself

```mermaid
sequenceDiagram
  participant F1 as Follower 1
  participant F2 as Follower 2
  participant F3 as Follower 3
  Note over F1,F3: Election timeout occurs on F1
  F1->>F1: Increment term, become Candidate
  F1->>F2: RequestVote(term=2)
  F1->>F3: RequestVote(term=2)
  F2-->>F1: Vote granted
  F3-->>F1: Vote granted
  Note over F1: Majority reached
  F1->>F1: Becomes Leader
  F1->>F2,F3: Send heartbeats (AppendEntries)
```

💡 Election timeouts are **randomized** (e.g., 150–300 ms) to avoid split votes.

---

### 🧮 3.3 Log Replication

```mermaid
sequenceDiagram
  participant Client
  participant Leader
  participant Follower1
  participant Follower2
  Client->>Leader: PUT /foo=bar
  Leader->>Leader: Append entry to local log
  Leader->>Follower1: AppendEntries(entry=foo=bar)
  Leader->>Follower2: AppendEntries(entry=foo=bar)
  Follower1-->>Leader: ACK
  Follower2-->>Leader: ACK
  Leader->>Leader: Mark entry committed
  Leader->>Client: Success (committed)
```

✅ Only after a **majority of nodes (quorum)** acknowledge does the leader commit.
✅ Each follower applies entries in identical order → consistent state.

---

### ⚡ 3.4 Read Paths: Linearizable vs Serializable

| Read Type        | Behavior                                    | Latency |
| ---------------- | ------------------------------------------- | ------- |
| **Linearizable** | Contact the current leader → always fresh   | Higher  |
| **Serializable** | Serve from any node (may be slightly stale) | Lower   |

Example:

- Kubernetes API Server uses **linearizable reads** for writes/updates.
- Monitoring tools may use **serializable reads** for speed.

---

## 💾 4. Storage Engine Internals

Etcd uses a **multi-versioned key-value store (MVCC)**.
Every mutation creates a _new revision_ — older versions remain accessible until compacted.

---

### 📁 4.1 Data Directory Structure

```ini
/var/lib/etcd/
├── member/
│   ├── snap/               # Snapshots
│   ├── wal/                # Write-Ahead Logs
│   └── memberID.json
└── proxy/
```

Each node persists its state here.

---

### 📜 4.2 Write-Ahead Log (WAL)

- Append-only log of Raft entries
- Synced to disk before applying changes
- Used to recover from crashes

Flow:

```text
Client PUT -> Raft Entry -> WAL -> State Machine -> Snapshot
```

---

### 🌳 4.3 B+Tree & BoltDB

Etcd uses **BoltDB** (a Go embedded B+Tree database).
Each key is stored under a revision index.

Example internal structure:

| Key                     | Revision | Value            |
| ----------------------- | -------- | ---------------- |
| /registry/pods/ns1/pod1 | 5        | Pod spec JSON    |
| /registry/nodes/node1   | 7        | Node status JSON |

---

### 🧱 4.4 MVCC (Multi-Version Concurrency Control)

- Every transaction gets a **revision number**
- Reads at revision X see the state as of X
- Enables consistent snapshots and watches

```mermaid
graph LR
  A[Rev 1: foo=bar] --> B[Rev 2: foo=baz] --> C[Rev 3: foo=qux]
```

Clients can query specific versions or watch from a revision.

---

## 👀 5. Watch System — Real-Time Change Streams

When something in etcd changes, watchers are triggered.
Perfect for systems like Kubernetes that react instantly to Pod/Config changes.

---

### 🔔 5.1 Watch Workflow

```mermaid
sequenceDiagram
  participant Client
  participant Etcd
  Client->>Etcd: Watch /registry/pods
  Etcd-->>Client: Snapshot (rev=10)
  Note right of Etcd: future changes streamed live
  Etcd-->>Client: PUT podA rev=11
  Etcd-->>Client: DELETE podB rev=12
```

✅ Efficient push model — no polling
✅ Ordered, reliable event stream
✅ Can resume from `startRevision`

---

## 🧹 6. Compaction and Snapshots

Without cleanup, the MVCC store grows indefinitely.
That’s where **compaction** and **snapshotting** come in.

---

### 🧽 6.1 Compaction

- Removes revisions older than a specific number
- Frees disk and memory
- Prevents old watches from growing unbounded

```bash
etcdctl compact 1000
```

After compaction, you can’t watch from earlier revisions.

---

### 📸 6.2 Snapshotting

Snapshots capture the full state at a revision.

Used for:

- Fast follower catch-up
- Backup & restore
- Log truncation

```bash
etcdctl snapshot save /backup/etcd-snap.db
```

---

## 🔄 7. Failure Recovery & Data Integrity

---

### 💥 7.1 Node Crash

- On restart, etcd replays WAL entries not in snapshot
- Restores last committed state
- Rejoins cluster and syncs missing logs from leader

---

### 🔁 7.2 Network Partition

- Only majority (quorum) continues committing
- Minority partition stops accepting writes
- Once partition heals, minority syncs via AppendEntries or snapshot

```mermaid
stateDiagram
  [*] --> Normal
  Normal --> Partition : Network issue
  Partition --> QuorumActive : Majority alive
  Partition --> Frozen : Minority lost quorum
  QuorumActive --> Normal : Recovered
  Frozen --> Normal : Rejoined
```

---

## 🧮 8. Internals of Raft Log Management

| Component           | Description                                                       |
| ------------------- | ----------------------------------------------------------------- |
| **unstable**        | Buffer of entries not persisted yet                               |
| **storage**         | Interface to persistent layer                                     |
| **committed index** | Highest index known to be safely replicated                       |
| **applied index**   | Highest entry applied to state machine                            |
| **Ready struct**    | Raft tells etcd: “Persist these entries and send these messages.” |

---

## 🧰 9. Operational Mechanics

---

### 🧩 9.1 Cluster Sizing

| Cluster Size | Tolerates Failures | Majority (Quorum) |
| ------------ | ------------------ | ----------------- |
| 3            | 1                  | 2                 |
| 5            | 2                  | 3                 |
| 7            | 3                  | 4                 |

Always use an **odd number** to maintain quorum.

---

### ⚙️ 9.2 Backup and Restore

```bash
# Create snapshot
etcdctl snapshot save /tmp/etcd-backup.db

# Restore to new cluster
etcdctl snapshot restore /tmp/etcd-backup.db \
  --name new-member \
  --initial-cluster new-member=http://127.0.0.1:2380 \
  --initial-advertise-peer-urls http://127.0.0.1:2380 \
  --data-dir /var/lib/etcd-new
```

---

## 🧠 10. etcd Inside Kubernetes

---

### 🧬 10.1 Control Plane Relationship

```mermaid
graph LR
  A[Kube API Server] --> B[etcd Leader]
  B --> C[etcd Followers]
  A --> D[Controller Manager]
  A --> E[Scheduler]
```

| Component              | Interaction                    |
| ---------------------- | ------------------------------ |
| **API Server**         | Direct gRPC connection to etcd |
| **Controller Manager** | Watches via API Server         |
| **Scheduler**          | Reads via API Server           |
| **kubectl**            | → API Server → etcd            |

The API server is the **only component** talking directly to etcd.

---

### 📡 10.2 API Server ↔ etcd Write Example

```mermaid
sequenceDiagram
  participant Kubectl
  participant API as API Server
  participant Etcd as etcd Leader
  Kubectl->>API: POST /api/v1/pods
  API->>Etcd: PUT /registry/pods/ns1/pod1
  Etcd-->>API: Success (revision=41)
  API-->>Kubectl: 201 Created
  Note right of Etcd: replicated via Raft to followers
```

---

## 🔍 11. Performance Optimization

Tips from production clusters:

| Area                              | Recommendation                                          |
| --------------------------------- | ------------------------------------------------------- |
| **Disk**                          | Use SSD/NVMe, disable write cache                       |
| **Network**                       | Low latency (<1 ms between peers)                       |
| **Snapshot frequency**            | Adjust via `--snapshot-count`                           |
| **Heartbeat & Election timeouts** | Tune for stability (default 100 ms / 1 s)               |
| **Monitor**                       | Use `etcdctl endpoint status` and metrics at `/metrics` |

---

## 🛡️ 12. Security (TLS Everywhere)

Etcd uses **mutual TLS** between all peers and clients.

Example config snippet:

```bash
etcd \
  --cert-file=/etc/etcd/server.crt \
  --key-file=/etc/etcd/server.key \
  --client-cert-auth=true \
  --trusted-ca-file=/etc/etcd/ca.crt
```

✅ Encrypts both client and peer traffic
✅ Ensures only authenticated nodes join cluster

---

## 🧮 13. Metrics and Observability

Expose Prometheus metrics:

```ini
GET http://localhost:2379/metrics
```

Key metrics:

- `etcd_server_leader_changes_seen_total`
- `etcd_disk_wal_fsync_duration_seconds`
- `etcd_network_peer_round_trip_time_seconds`
- `etcd_mvcc_db_total_size_in_bytes`

---

## 🧩 14. Example Failure Scenario — Leader Crash Recovery

```mermaid
sequenceDiagram
  participant C1 as Client
  participant L as Leader (etcd1)
  participant F1 as Follower (etcd2)
  participant F2 as Follower (etcd3)
  C1->>L: PUT key=value
  L->>F1,F2: AppendEntries
  F1-->>L: ACK
  F2-->>L: ACK
  L->>L: Commit
  Note over L: Suddenly crashes 💥
  F1->>F1: Election timeout triggers
  F1->>F2: RequestVote
  F2-->>F1: Granted
  F1->>F1: Becomes new leader
  C1->>F1: Continues writing safely
```

Zero data loss thanks to majority replication.

---

## 🧠 15. Summary — Why etcd is a Jewel of Kubernetes

✅ **Strong Consistency** — every read/write is predictable
✅ **Raft-based reliability** — safe leader elections, no split-brain
✅ **Efficient Storage** — MVCC + compaction + snapshot
✅ **Reactive System** — watch API drives K8s controllers
✅ **Secure by design** — TLS, client authentication
✅ **Simple but robust** — one binary, well-defined gRPC API

---

## 📚 16. Key Commands Cheat Sheet

| Purpose              | Command                         |
| -------------------- | ------------------------------- |
| List cluster members | `etcdctl member list`           |
| Health check         | `etcdctl endpoint health`       |
| Store key            | `etcdctl put foo bar`           |
| Get key              | `etcdctl get foo`               |
| Watch key            | `etcdctl watch foo`             |
| Snapshot backup      | `etcdctl snapshot save snap.db` |
| Compact              | `etcdctl compact 1000`          |

---

## 🧩 17. Visual Summary

```mermaid
graph TD
  subgraph Etcd Cluster
    L[Leader] --> F1[Follower 1]
    L --> F2[Follower 2]
    L --> W[WAL + B+Tree]
  end
  C[Client / API Server] -->|gRPC| L
  W --> S[Snapshot & Compaction]
  L --> W2[Watchers]
```

Etcd = consensus-powered brain of Kubernetes 🧠💎
