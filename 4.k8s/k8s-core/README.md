# ☸️ Admin Curriculum — Docs per Workload (small #, big depth)

Below I propose the **number of docs per topic** and **exact doc titles**. Each doc is meant to be long (400+ lines), hands-on, and strictly admin-focused (create, manage, troubleshoot, secure, automate).

---

## 1) **Pods** — 6 docs

1. **Pods 101: Creation, Inspection & Lifecycle (Admin Essentials)**
   `kubectl run/apply`, YAML anatomy, labels/annotations, lifecycle phases, restart policy, multi-container pods, init containers, sidecars, ephemerals, port-forward.
2. **Probes, Health & Graceful Shutdown**
   liveness/readiness/startup probes, terminationGracePeriod, preStop hooks, draining behavior, rollout health, common probe failures.
3. **Scheduling, Placement & Pod Disruption**
   nodeSelector/affinity/anti-affinity, taints/tolerations, topology spread, PDBs (disruption budgets), eviction handling, priority/preemption.
4. **Resources, QoS & Limits**
   requests/limits, QoS classes (Guaranteed/Burstable/BestEffort), limitRange defaults, throttling behavior, OOMKill diagnosis.
5. **Networking & Storage at Pod Level**
   Pod IPs, DNS inside pods, downward API, projected volumes, ephemeral & persistent volumes mounting patterns, config/env injection.
6. **Troubleshooting & Debugging Pods**
   CrashLoopBackOff, ImagePullBackOff, Pending, ContainerCreating, Terminating, `kubectl logs/exec/describe`, `kubectl debug` with ephemeral containers, node vs pod issues.

---

## 2) **ReplicaSets** — 2 docs

1. **ReplicaSets in Practice: Scaling & Consistency**
   desired vs current replicas, label selectors, adoption/orphaning, surge/availability basics (as seen via Deployments).
2. **Troubleshooting ReplicaSets**
   mis-selectors, pending pods, resources insufficient, events analysis, when to use RS directly vs via Deployments.

---

## 3) **Deployments** — 5 docs

1. **Deployments 101: Spec, Strategy & Rollout Control**
   rollingUpdate config (maxUnavailable/maxSurge), pause/resume, canary-ish with multiple Deployments, image updates.
2. **Rollbacks, History & Versioning**
   `rollout status/history/undo`, annotations for traceability, safe rollback patterns, failure windows.
3. **Scaling & Availability**
   HPA with Deployments, PDBs with Deployments, surge vs disruption tradeoffs, upgrade windows.
4. **Zero-Downtime Patterns**
   readiness gates, preStop hooks, graceful termination budgets, connection draining with LB/Ingress.
5. **Deployment Troubleshooting**
   stuck rollouts, failing probes during rollout, image pull/auth errors, node pressure, event-driven diagnosis.

---

## 4) **StatefulSets** — 4 docs

1. **StatefulSets 101: Identity, Storage & Ordering**
   stable network IDs, ordered deployment/termination, PVC templates, Headless Services, partitioned updates.
2. **Storage Deep Dive for StatefulSets**
   storageClass, volumeBindingMode, resizing, backups/snapshots, moving PVCs safely.
3. **Scaling & Rolling Updates**
   ordinal management, surge-like strategies, partitioned rollouts, safe schema/data migrations.
4. **Troubleshooting StatefulSets**
   stuck PVCs, volume attach failures, pod identity issues, failover patterns, quorum apps (DBs).

---

## 5) **DaemonSets** — 3 docs

1. **DaemonSets 101: Cluster-Wide Agents**
   scheduling on all/selected nodes, tolerations for masters, host networking/paths, update strategies.
2. **Node Targeting & Upgrades**
   selective deployment via node labels, surge-like rolling for DaemonSets, cordon/drain interactions.
3. **Troubleshooting DaemonSets**
   missing nodes, taints/tolerations mismatches, host resource conflicts, CrashLoop diagnostics.

---

## 6) **Jobs & CronJobs** — 3 docs

1. **Jobs 101: Completions, Parallelism & Retries**
   backoffLimit, activeDeadlineSeconds, parallel workers, idempotence patterns.
2. **CronJobs in Production**
   schedules, concurrencyPolicy, history limits, missed runs, timezones, observability.
3. **Troubleshooting Jobs/CronJobs**
   stuck jobs, repeated failures, logs retention, cleanup automation and quotas.

---

## 7) **Services** — 3 docs

1. **Services 101: ClusterIP/NodePort/LoadBalancer**
   selectors/endpoints, sessionAffinity, externalTrafficPolicy, health behavior.
2. **Service Discovery & Diagnostics**
   DNS (`svc.cluster.local`), headless services, endpointslices, probing service reachability.
3. **Troubleshooting Services**
   no endpoints, iptables/IPVS issues, nodePort clashes, cloud LB provisioning failures.

---

## 8) **Ingress (with a Controller like Traefik/Nginx)** — 4 docs

1. **Ingress 101: Rules, Hosts, Paths**
   pathType, annotations/CRDs, multiple backends, default backends.
2. **TLS & Certificates**
   secrets, Let’s Encrypt (ACME), mTLS, rotation, renewals.
3. **Advanced Routing & Middlewares**
   headers, rate limiting, auth, rewrites/redirects (Traefik middlewares / Nginx annotations).
4. **Troubleshooting Ingress**
   404/502/503, bad backends, LB health probes, mismatch between Service/Ingress.

---

## 9) **ConfigMaps & Secrets** — 3 docs

1. **Config Injection Patterns**
   env vars, volume mounts, projected configs, large configs, hot-reload patterns.
2. **Secrets: Handling & Security**
   creation/rotation, CSI drivers, encryption at rest, external secret managers.
3. **Troubleshooting Config/Secret Issues**
   mount failures, wrong keys, reload not applied, rollout strategy for config changes.

---

## 10) **Persistent Volumes & Claims** — 4 docs

1. **PV/PVC 101: Binding Models**
   static vs dynamic provisioning, reclaim policies, access modes, volumeModes.
2. **StorageClasses & Provisioners**
   parameters per cloud, topology constraints, delayed binding, performance classes.
3. **Data Ops**
   resizing, cloning, snapshots, backup/restore, migration.
4. **Troubleshooting Storage**
   Pending PVCs, attach/detach failures, node affinity, filesystem errors.

---

## 11) **Namespaces & Quotas** — 3 docs

1. **Namespaces for Multi-Tenancy**
   creation, defaults, context switching, org structure, labels.
2. **ResourceQuota & LimitRange Administration**
   caps, defaults, governance patterns, show-back.
3. **Troubleshooting Namespace/Quota**
   terminating namespaces, finalizers, denied creations due to quota/limits.

---

## 12) **RBAC & ServiceAccounts** — 3 docs

1. **RBAC 101: Roles & Bindings**
   namespaced vs cluster, verbs/resources, least privilege.
2. **ServiceAccounts & Workload Identity**
   tokens, projected service account tokens, external identity providers.
3. **Troubleshooting Access**
   forbidden errors, `--as` impersonation, audit trails.

---

## 13) **Cluster Ops (Nodes & Maintenance)** — 4 docs

1. **Node Admin: Labels, Taints & Lifecycle**
   cordon/drain/uncordon, maintenance windows, upgrades interplay.
2. **Metrics & Capacity Management**
   Metrics Server, `kubectl top`, node pressure, eviction signals.
3. **Operational Toolbelt**
   `kubectl debug`, `kubectl cp`, `kubectl auth`, `kubeadm` basics.
4. **Troubleshooting Nodes**
   NotReady, kubelet issues, container runtime problems, disk/CPU pressure.

---

## 14) **Autoscaling** — 2 docs

1. **HPA in Production**
   metrics sources, stabilization windows, scale-to-zero patterns, readiness impact.
2. **Troubleshooting HPA**
   why it won’t scale, metrics gaps, over/under scaling, cool-down tuning.

---

## 15) **Helm & Release Operations** — 3 docs

1. **Helm 101: Install/Upgrade/Rollback**
   values, dependencies, chart structure, diff/verify.
2. **Multi-Env & Templates**
   env-specific values, secrets, schema validation, linting.
3. **Troubleshooting Helm Releases**
   failed upgrades, drift detection, atomic upgrades, hooks.

---

### Why this layout?

- **Small number of docs per topic** (2–6 each) → easy to track.
- **Every doc is big and deep** → admin workflows, commands, and troubleshooting in one place.
- **Predictable template** → once you learn the pattern in Pods, you fly through others.

---

## Recommended Sequence (Minimal Context Switching)

1. **Pods (6)** → **Deployments (5)** → **ReplicaSets (2)** → **DaemonSets (3)** → **StatefulSets (4)** → **Jobs/CronJobs (3)**
2. **Services (3)** → **Ingress (4)** → **Networking troubleshooting sprinkled inside**
3. **ConfigMaps/Secrets (3)** → **PV/PVC/Storage (4)**
4. **Namespaces & Quotas (3)** → **RBAC/ServiceAccounts (3)**
5. **Cluster Ops (4)** → **Autoscaling (2)** → **Helm (3)**

This gives you ~**54 total docs**—compact enough to finish, large enough to be authoritative.

---

If you’re happy with this structure, I’ll start writing **Pods — Doc 1: _“Pods 101: Creation, Inspection & Lifecycle (Admin Essentials)”_** exactly in your preferred style (long, complete, hands-on).
