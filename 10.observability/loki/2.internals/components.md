# 🧩 The `8 Loki components`, grouped by **category**

Think of Loki as 3 pipelines:

- **Write path**: accept logs → replicate → buffer → flush to object store
- **Read path**: accept queries → split/parallelize → fetch chunks → return results
- **Backend/control plane**: index plumbing + compaction + scheduling + rules

## ✅ Write path (ingestion)

These are the “logs are coming in right now!” components.

### 📌 1. **Distributor (D)** — “Traffic cop for logs”

- Receives incoming pushes from Promtail/agents (`/loki/api/v1/push`)
- Validates labels/limits, applies tenant settings
- Hashes each stream and chooses which ingesters should own it
- Ensures **replication factor** (send same data to multiple ingesters)

**Mental model:** _Load balancer + sharding router for logs._

---

### 📌 2. **Ingester (I)** — “Hot buffer + flush machine”

- Holds log data in-memory as **chunks**
- Periodically **flushes chunks** to **object storage**
- Keeps recent data “hot” so queries can read fresh logs quickly
- Often uses **WAL on disk** so a restart doesn’t lose recent unflushed logs

**Mental model:** _RAM cache for recent logs + durable flush to the bucket._

---

## ✅ Read path (query execution)

These are the “user asks a question: show me logs” components.

### 📌 3. **Query Frontend (FE)** — “Query optimizer + splitter”

- Receives queries (`/loki/api/v1/query_range`, etc.)
- Splits big time-range queries into smaller chunks
- Does queueing, retrying, caching (results cache)
- Makes queries cheaper and safer for the cluster

**Mental model:** _API gateway for queries + “make this query run fast” brain._

---

### 📌 4. **Querier (Q)** — “Worker that actually runs the query”

- Executes the query pieces given by FE
- Reads:
  - **index** (to find which chunks might match)
  - **chunks** from object storage
  - recent data from ingesters (depending on setup)

- Merges partial results

**Mental model:** _The CPU muscle that searches logs._

---

### 📌 5. **Query Scheduler (QS)** — “Air traffic control for queriers”

- Optional but very helpful at scale
- Central queue that feeds queriers fairly
- Prevents one user/dashboard from starving everything else
- Helps you scale queriers without chaos

**Mental model:** _Fair queue + traffic shaping for query execution._

---

## ✅ Backend / control plane (index + lifecycle + automation)

These are the “keeps Loki healthy and efficient over time” components.

### 📌 6. **Index Gateway (IG)** — “Index cache and index access layer”

- Loki index lives in object storage (or shipped index)
- IG reduces expensive object-store calls by caching/serving index data
- Improves query latency + reduces cost (fewer GETs)

**Mental model:** _CDN for index metadata._

---

### 📌 7. **Compactor (C)** — “Storage janitor + organizer”

- Compacts index blocks to keep them efficient
- Applies retention/deletes (depends on your retention setup)
- Writes temporary files while compacting ⇒ often needs disk

**Mental model:** _Garbage collector + defragmenter for Loki storage._

---

### 📌 8. **Ruler (R)** — “Alerting engine for logs”

- Evaluates LogQL rules periodically (like Prometheus rules, but for logs)
- Sends alerts to Alertmanager or writes recording rules output
- Usually backend-ish (not on hot ingestion path)

**Mental model:** _Scheduled queries + alert triggers._

---

## 🏁 Quick cheat-sheet: “who talks to object storage?”

- **Write path**: Ingester flushes chunks → object storage ✅
- **Read path**: Querier reads chunks/index from object storage ✅
- **Backend**: Compactor and Index Gateway interact heavily with object storage ✅

---

## 🚀 Deployment modes (and why they exist)

Loki can run the same “8 roles” in different shapes.

### ⚙️ Monolithic (Single Binary)

One process contains multiple roles inside it.

Your first diagram shows one **Loki binary** holding several components.

✅ Pros:

- Easiest to run
- Great for dev/small setups

❌ Cons:

- Scaling is blunt (scale everything together)
- No separation of read vs write load

---

### 🤹🏻‍♀️ Simple Scalable (SSD mode)

This is what you’re using.

Instead of running 8 separate microservices, Loki bundles them into **3 targets**:

#### 1. **write target** (stateful)

Contains:

- **Distributor (D)**
- **Ingester (I)**

#### 2. **read target** (stateless logically)

Contains:

- **Query Frontend (FE)**
- **Querier (Q)**

#### 3. **backend target** (stateful)

Contains:

- **Compactor (C)**
- **Index Gateway (IG)**
- **Query Scheduler (QS)**
- **Ruler (R)** (often here)

✅ Pros:

- You can scale **write** independently from **read**
- Much simpler than full microservices
- “Production-ready sweet spot” for most teams

❌ Cons:

- Still bundled: you can’t scale querier without also scaling FE (inside the read target)
- Less granular than full distributed microservices

Your 2nd diagram is literally: **3 write pods + 2 read pods + 1 backend pod**, all talking to object storage.

---

### 🦠 Microservices / Distributed mode

Each component runs as its own Deployment/StatefulSet.

- Distributor separate
- Ingester separate
- FE separate
- Querier separate
- IG separate
- Compactor separate
- QS separate
- Ruler separate

✅ Pros:

- Maximum scaling control and efficiency
- Best for very large clusters

❌ Cons:

- More moving parts, more ops complexity

---

## 🎯 Mapping table: components → category → SSD target → microservices

| Component            | Category                    | SSD target  | Stateful?                                       |
| -------------------- | --------------------------- | ----------- | ----------------------------------------------- |
| Distributor (D)      | Write                       | **write**   | No (but part of write set)                      |
| Ingester (I)         | Write                       | **write**   | **Yes** (needs persistence/WAL)                 |
| Query Frontend (FE)  | Read                        | **read**    | No                                              |
| Querier (Q)          | Read                        | **read**    | No                                              |
| Query Scheduler (QS) | Backend (query control)     | **backend** | No (usually)                                    |
| Index Gateway (IG)   | Backend (index/cache)       | **backend** | Often yes-ish (benefits from disk cache)        |
| Compactor (C)        | Backend (storage lifecycle) | **backend** | Often yes (working dir)                         |
| Ruler (R)            | Backend (automation)        | **backend** | Usually stateless (but depends on rule storage) |

---

## 💡 “Which component goes where” in your SSD Helm install

If you’re using Simple Scalable, you mainly tune:

- `write.replicas` (D + I together)
- `read.replicas` (FE + Q together)
- `backend.replicas` (C + IG + QS + R together)

That’s why in SSD you size by **target**, not by the individual component count.
