# 🧭 Goal

Become “**minimally independent**” in:

- Linux troubleshooting 🧑‍💻
- Kubernetes administration ⚙️
- Terraform & IaC 🧱
- Observability & debugging 🧩
- Cloud + networking fundamentals ☁️

---

## 🧱 1. Linux Essentials (7 days)

You don’t need to be a sysadmin — you need _engineering-level comfort_.
Focus on **diagnosing, navigating, and debugging**.

### 🎯 Must-Learn Commands & Concepts

| Area               | Key Commands / Concepts                                                              | Why it Matters                                     |
| ------------------ | ------------------------------------------------------------------------------------ | -------------------------------------------------- |
| File & directories | `cd`, `ls -lah`, `cat`, `less`, `head`, `tail -f`, `grep`, `find`, `du -sh`, `df -h` | You’ll inspect logs, configs, and disk space daily |
| Process & memory   | `top`, `htop`, `ps aux`, `free -h`, `kill -9`, `uptime`, `vmstat`, `lsof`            | Identify high CPU/memory processes                 |
| Networking         | `ping`, `curl`, `wget`, `netstat`, `ss`, `nslookup`, `dig`, `traceroute`             | For connectivity, DNS, port checks                 |
| Permissions        | `chmod`, `chown`, `sudo`, `/etc/sudoers`, `groups`, `adduser`, `passwd`              | Fix “permission denied” errors fast                |
| Services           | `systemctl`, `journalctl`, `/var/log/syslog`                                         | Check failed services, restarts                    |
| Package mgmt       | `apt`, `yum`, `dnf`                                                                  | Install troubleshooting tools                      |
| Disk ops           | `mount`, `df`, `lsblk`, `fdisk`                                                      | Verify GPU/compute nodes’ volumes                  |
| SSH keys           | `ssh-keygen`, `ssh user@host`, `scp`, `.ssh/config`                                  | Remote access — essential for cluster nodes        |

### 🧠 Mini Project

Spin up an **Ubuntu EC2** (or local VM).
Do:

1. Create users, add sudoers.
2. Install Nginx.
3. Tail access logs, restart service, check ports.
4. Add firewall rule (UFW) and test.

---

## ☸️ 2. Kubernetes Administration (6 days)

They expect you to fix stuck pods, GPU alloc, and multi-tenant issues — not design clusters yet.

### 🎯 Learn These First

| Skill           | Command/Concept                                                                   | Why                               |
| --------------- | --------------------------------------------------------------------------------- | --------------------------------- |
| Basic objects   | Pods, Deployments, Services, ConfigMaps, Secrets, Namespaces                      | Core building blocks              |
| Troubleshooting | `kubectl get pods -A`, `kubectl describe pod`, `kubectl logs`, `kubectl exec -it` | You’ll diagnose failed jobs daily |
| Scaling         | `kubectl scale`, `kubectl rollout restart`, readiness probes                      | Restarting stuck workloads        |
| Resource mgmt   | `requests`, `limits`, `nvidia.com/gpu`                                            | GPU scheduling                    |
| Contexts        | `kubectl config get-contexts`, `kubectl config use-context`                       | Switching clusters                |
| Events          | `kubectl get events --sort-by=.metadata.creationTimestamp`                        | Find cause of failure             |
| Nodes           | `kubectl get nodes -o wide`, `kubectl cordon/drain`                               | Maintenance ops                   |

### 🧠 Mini Project

Use **kind** (local Kubernetes) or **Play with Kubernetes**:

1. Deploy an Nginx app with a ConfigMap.
2. Simulate crash (`kubectl delete pod`) and watch auto-restart.
3. Add a resource limit.
4. View logs, describe events.

---

## 🪄 3. Terraform & IaC (3 days)

They mention Terraform/Ansible — pick Terraform first.

### 🎯 Learn

- `.tf` structure (provider, resource, variable, output).
- `terraform init`, `plan`, `apply`, `destroy`.
- Provision:

  - 1 EC2 + Security Group
  - 1 S3 bucket

- Use variables and outputs.

🧠 **Goal:** Be able to read any Terraform code and know what it deploys.

---

## 🧰 4. Observability & Debugging (2 days)

You’ll need to handle metrics, logs, and alerts.

### Focus:

- **Prometheus / Grafana basics** — understand metrics queries (`up`, `rate`, dashboards).
- **Logs** — know difference between `journalctl`, `kubectl logs`, app logs.
- **Linux performance** — CPU throttling, memory usage, disk I/O (`iostat`, `sar`).
- **Cloud monitoring** — AWS CloudWatch or Azure Monitor (just basics).

---

## 🌐 5. Networking & Storage (2 days)

Understand the fundamentals:

- IP, subnet, gateway, DNS resolution
- `ping` / `curl` / `traceroute` / `dig` usage
- S3 concepts: buckets, policies, sync commands
- Ceph / Lustre overview (YouTube or free course — just architecture level)

---

## 🧠 6. Scripting (Optional 2 days)

At least one language for automation:

- **Bash:** loops, `if`, variables, `grep`, `awk`, `sed`, writing `.sh` scripts.
- **Python:** if you already know it (as a backend dev), just learn how to call system commands via `subprocess` and parse logs.

---

## 🏋️ 20-Day Plan Summary

| Day   | Focus                                                         |
| ----- | ------------------------------------------------------------- |
| 1–7   | Linux (commands, logs, permissions, services, SSH)            |
| 8–13  | Kubernetes (pods, deployments, logs, events, troubleshooting) |
| 14–16 | Terraform basics (infra deployment)                           |
| 17–18 | Observability (Prometheus, logs, metrics)                     |
| 19–20 | Networking + scripting basics                                 |

---

## ⚙️ Bonus Tips for Confidence

> ✅ Don’t over-study — **focus on survival tasks**, not architecture theory.  
> ✅ Keep a personal **“Troubleshooting Cheatsheet”** — command, meaning, fix example.  
> ✅ Watch these **YouTube channels daily (20 min)**:

- _TechWorld with Nana_ — K8s, Terraform, Prometheus
- _NetworkChuck_ — Linux & networking
- _Deekshith SN / DevOps Toolkit_ — real troubleshooting demos

---

Would you like me to make you a **20-day daily study plan table (with resources & exact labs)** for this role — like a “bootcamp before joining” checklist? It’ll show what to do each day and include the exact videos and labs (all free).
