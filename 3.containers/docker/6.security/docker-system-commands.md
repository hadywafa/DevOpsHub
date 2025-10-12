Perfect 🔥 — now you’re diving into **advanced Docker CLI territory** where you don’t just run containers, but also **observe, debug, and manage** what’s happening behind the scenes.

Let’s go through the **“docker system” commands** — including the famous `docker system events` — in a **simple, structured, and visual way** so you’ll understand what each does, why it exists, and when to use it 🚀

---

# 🧭 Overview — `docker system` Command Family

`docker system` commands are **admin-level tools** to inspect, clean, and monitor the Docker engine itself —
not individual containers or images, but the *whole Docker environment*.

They mainly help with:

* Checking system usage (disk, memory)
* Monitoring live events
* Cleaning up unused data
* Debugging daemon activity

---

# ⚙️ Command List (Quick Summary)

| Command                | Purpose                                        |
| ---------------------- | ---------------------------------------------- |
| `docker system df`     | Show disk usage by images, containers, volumes |
| `docker system info`   | Display detailed Docker daemon info            |
| `docker system events` | Stream real-time Docker events                 |
| `docker system prune`  | Delete unused data (cleanup)                   |
| `docker system df -v`  | Detailed view with object breakdown            |

We’ll go one by one 👇

---

## 🧮 1️⃣ `docker system df` — Disk Usage Overview

Shows how much space Docker objects are using on disk.

```bash
docker system df
```

Example output:

```
TYPE            TOTAL     ACTIVE    SIZE      RECLAIMABLE
Images          10        3         2.35GB    1.9GB (80%)
Containers      5         1         300MB     250MB (83%)
Local Volumes   3         2         1.1GB     800MB (72%)
Build Cache     4                   350MB     300MB (85%)
```

### 💡 Notes:

* “Reclaimable” means Docker could free that space if you prune.
* Add `-v` for **verbose** mode to see individual image/container paths:

  ```bash
  docker system df -v
  ```

---

## 🧹 2️⃣ `docker system prune` — Cleanup Command

Deletes **all unused**:

* Stopped containers
* Dangling images (untagged)
* Unused networks
* Build cache
* (Optionally) unused volumes

```bash
docker system prune
```

You’ll see:

```
WARNING! This will remove:
  - all stopped containers
  - all networks not used by at least one container
  - all dangling images
  - all build cache
Are you sure you want to continue? [y/N]
```

To skip confirmation:

```bash
docker system prune -f
```

To include **unused volumes** too:

```bash
docker system prune -a --volumes
```

### ⚠️ Be careful

It can free up gigabytes — but can also delete things you still need.

---

## 🧾 3️⃣ `docker system info` — Engine Health and Environment

Shows complete details about the **Docker daemon** and host system.

```bash
docker system info
```

Example output:

```
Client:
 Context: default
 Debug Mode: false

Server:
 Containers: 8
  Running: 3
  Paused: 0
  Stopped: 5
 Images: 12
 Server Version: 27.0.1
 Storage Driver: overlay2
  Backing Filesystem: ext4
 Cgroup Driver: systemd
 Logging Driver: json-file
 Plugins:
  Volume: local
  Network: bridge, host, none
 Swarm: inactive
 Runtimes: runc
 Kernel Version: 6.8.0-45-generic
 Operating System: Ubuntu 22.04 LTS
 Architecture: x86_64
```

### 💡 Notes:

* Great for verifying daemon setup
* Shows **cgroup driver**, **storage driver**, and **network plugins**
* Useful in troubleshooting daemon startup issues

---

## ⚡ 4️⃣ `docker system events` — Live Event Stream (Real-Time Monitoring)

This is one of Docker’s **most powerful hidden gems** ⚡

It lets you **watch the Docker daemon in real time**, showing events as they happen —
like container creation, start, stop, network connect, volume attach, etc.

---

### ▶️ Basic usage

```bash
docker system events
```

You’ll see a **live feed** of events such as:

```
2025-10-11T11:15:02.563594437Z container create 3f7b4a8e12c7 (image=nginx, name=test)
2025-10-11T11:15:02.682973219Z network connect 3f7b4a8e12c7 (network=bridge, name=test)
2025-10-11T11:15:03.785332894Z container start 3f7b4a8e12c7 (image=nginx, name=test)
2025-10-11T11:16:03.005584109Z container die 3f7b4a8e12c7 (exitCode=0)
```

💡 This is Docker’s **event bus**, showing all daemon activities as they occur.

---

### ⏱️ Filtering by time

Use `--since` and `--until` to get historical events.

```bash
docker system events --since 10m
```

→ Shows events from the last 10 minutes.

Or:

```bash
docker system events --since "2025-10-11T09:00:00" --until "2025-10-11T10:00:00"
```

---

### 🎯 Filtering by type or action

You can filter by **type**, **event**, or **container**:

```bash
# Show only container events
docker system events --filter 'type=container'

# Show only image events
docker system events --filter 'type=image'

# Show only start events
docker system events --filter 'event=start'

# Show events for a specific container
docker system events --filter 'container=myapp'
```

---

### 📋 Example use cases

| Use Case                 | Command                                      | What It Shows              |
| ------------------------ | -------------------------------------------- | -------------------------- |
| See all container starts | `docker system events --filter event=start`  | When containers begin      |
| Monitor image pulls      | `docker system events --filter type=image`   | Image-related operations   |
| Debug network issues     | `docker system events --filter type=network` | Connections/disconnections |
| Monitor everything live  | `docker system events`                       | Full system feed           |

---

### 🧠 Why It’s Useful

* Real-time auditing — see who/what triggers Docker actions
* Debugging — detect containers being killed or restarted unexpectedly
* Monitoring — feed these events into systems like **Prometheus**, **ELK**, or **Datadog**

You can even stream them to a file:

```bash
docker system events > /var/log/docker-events.log
```

---

### ⚙️ Under the Hood

* These events come directly from the **Docker Daemon’s event subsystem**.
* Internally, the daemon emits events whenever state changes (container create, image pull, volume mount, etc.).
* The CLI just streams them over the Docker API.

Equivalent REST API:

```bash
curl --unix-socket /var/run/docker.sock http://localhost/events
```

---

# 🧠 5️⃣ Bonus — `docker events` (alias)

`docker system events` and `docker events` are **identical**.
Both point to the same daemon API.

So these two do exactly the same:

```bash
docker system events
docker events
```

---

# 💡 Practical Example (Try This)

Open two terminals:

**Terminal 1:**

```bash
docker system events
```

**Terminal 2:**

```bash
docker run --rm nginx
docker stop $(docker ps -q)
```

Back in Terminal 1 — you’ll see:

```
container create <id> (image=nginx)
container start <id>
container die <id>
container destroy <id>
```

This helps you **understand the exact order** of Docker’s lifecycle events.

---

# 🧾 TL;DR Summary

| Command                | Purpose                | Common Options                   |
| ---------------------- | ---------------------- | -------------------------------- |
| `docker system df`     | Show disk usage        | `-v` for detailed                |
| `docker system prune`  | Cleanup unused data    | `-a`, `--volumes`, `-f`          |
| `docker system info`   | System and daemon info | *(none)*                         |
| `docker system events` | Real-time event stream | `--since`, `--filter`, `--until` |

---

# ⚡ Mnemonic to Remember

> **“Docker System = Doctor’s Stethoscope 🩺”**

It lets you **hear and clean** the Docker engine’s heartbeat:

* **df** → Diagnose disk
* **info** → Inspect system
* **events** → Hear live logs
* **prune** → Purge junk

---

Would you like me next to show you **how to interpret and react programmatically** to Docker system events (for example, using Python or Bash to auto-restart or log actions)? That’s how many monitoring tools are built under the hood.
