# 🧠 **ETCD Made Easy**

_Think of it as **Kubernetes’ brain and memory**._

## 💡 What It Is

- **etcd** = a **distributed, consistent key-value database** used by **Kubernetes** to store everything (Pods, Nodes, ConfigMaps, etc.).

---

## ⚙️ **How It Works (Big Picture)**

1. **Kubernetes API Server** talks to etcd via **gRPC**.
2. **etcd cluster** = 3–5 nodes (for redundancy).
3. **One node is the Leader** → handles writes.
4. **Others are Followers** → replicate the data.

---

## 🔁 **Consensus via Raft**

Raft = the algorithm that keeps everyone in sync.

- **Leader** manages writes
- **Followers** copy the log
- **Majority (quorum)** must agree before commit
- If leader dies → **new leader is elected**

🪄 Randomized election timeout prevents split votes.

---

## 💾 **Data Storage Flow**

1. Write request → goes to **Leader**
2. Leader writes to **WAL (Write-Ahead Log)**
3. Log entries sync to followers
4. Once a **majority ACKs**, entry is **committed**
5. Data stored in **B+Tree (BoltDB)**
6. Old versions are kept (MVCC)

---

## 👀 **Watchers**

- Clients can “watch” keys → get live updates (no polling).
- Used by Kubernetes controllers for instant reactions.

---

## 🧹 **Compaction & Snapshots**

- **Compaction** removes old revisions.
- **Snapshots** = full backup of the current state.
  Used for recovery or catching up new members.

---

## 🔄 **Failures**

- **Node crash:** Replay WAL + restore snapshot.
- **Network split:** Only majority keeps working; minority freezes until rejoined.

---

## 🧰 **In Kubernetes**

- Only **API Server** talks to etcd.
- Controllers, Scheduler, and `kubectl` go through API Server.
- Ensures consistent and reliable cluster state.

---

## 🧩 **Key Commands**

| Task            | Command                         |
| --------------- | ------------------------------- |
| Health check    | `etcdctl endpoint health`       |
| Save key        | `etcdctl put foo bar`           |
| Read key        | `etcdctl get foo`               |
| Watch key       | `etcdctl watch foo`             |
| Snapshot backup | `etcdctl snapshot save snap.db` |
| Compact         | `etcdctl compact <rev>`         |

---

## 🚀 **Remember in 10 Seconds**

> **etcd = distributed key-value brain of Kubernetes**  
> → uses **Raft** for leader consensus  
> → **WAL + B+Tree** for durable storage  
> → **MVCC** for versioned reads  
> → **Watchers** for instant updates  
> → **Compaction/Snapshot** for cleanup and recovery
