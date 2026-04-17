# Kubernetes Resource Monitoring: Why Azure Monitor and kubectl Disagree — And How to Get the Truth

## 1. The Problem

You're running an AKS cluster with a **Standard_D8s_v3** node (8 vCPUs, 32 GB RAM). Two monitoring sources tell you conflicting stories:

|Source|What It Says|Reality|
|---|---|---|
|**Azure Monitor**|~3 GB available memory (~90% used)|Actual OS-level free RAM on the VM|
|**kubectl describe node**|18.7 GB requested / 62% reserved|Kubernetes scheduler bookkeeping|

The node appears healthy according to Kubernetes but is dangerously close to OOM (Out of Memory) at the OS level.

---

## 2. Understanding the Two Layers

### Layer 1: Kubernetes Scheduler View (`kubectl describe node`)

Kubernetes tracks **requests** and **limits** — values declared in pod specs:

- **Requests**: The guaranteed minimum a pod is promised. The scheduler uses this to decide where to place pods.
- **Limits**: The maximum a pod is allowed to consume. Enforced by the Linux kernel (cgroups).

When `kubectl describe node` shows:

```
cpu     4744m (60%)    7710m (98%)
memory  18751Mi (62%)  33675Mi (112%)
```

This means:

- 60% of CPU capacity is **reserved** (not necessarily used)
- 62% of memory is **reserved** (not necessarily used)
- Memory **limits** are overcommitted at 112% — if all pods hit their limits simultaneously, the node will OOM

### Layer 2: OS/VM View (Azure Monitor)

Azure Monitor queries the actual Linux kernel (`/proc/meminfo`) on the VM. It reports real, physical memory consumption — including:

- Kernel and OS overhead (~1.5–2 GB on AKS nodes)
- Kubelet and system daemons
- ALL running containers, whether they declared requests or not
- Filesystem caches and buffers

---

## 3. Why They Disagree — Your Specific Case

Looking at your node, **~45 out of 62 pods have zero resource requests**:

```
b2b-bss-dev-be   admin-service-ccf6776b7-g66pb     0 (0%)   0 (0%)   0 (0%)    0 (0%)
b2b-bss-dev-be   cache-service-7dbfffdf5c-r7qp2    0 (0%)   0 (0%)   0 (0%)    0 (0%)
b2b-bss-dev-be   document-service-7c96654b69-tcvzw  0 (0%)   0 (0%)   0 (0%)    0 (0%)
...dozens more with 0 (0%) across the board...
```

These pods are invisible to the Kubernetes scheduler — it thinks they consume nothing. But they absolutely consume real CPU and memory on the VM. This is the entire source of the discrepancy.

Meanwhile, your **observability stack alone** is very heavy:

|Pod|Memory Request|Memory Limit|
|---|---|---|
|loki-chunks-cache-0|9,830 Mi|9,830 Mi|
|prometheus-dev-prometheus-0|2 Gi|4 Gi|
|loki-read|1 Gi|2 Gi|
|loki-write-0|1 Gi|2 Gi|
|grafana|256 Mi|1 Gi|
|**Total observability**|**~15 Gi**|**~22 Gi**|

Your observability stack is consuming nearly half the node's total RAM.

---

## 4. The Risks of This Situation

### Risk 1: OOM Kills

With only ~3 GB free and memory limits overcommitted at 112%, a traffic spike will trigger Linux OOM killer. It will kill pods — and not necessarily the right ones.

### Risk 2: Incorrect Scheduling

The scheduler sees 38% of memory as "unreserved" and may schedule new pods on this node. Those pods will land on a node that's already at 90% actual usage.

### Risk 3: No Eviction Protection

Without requests, pods get **BestEffort** QoS class — they are the first to be evicted under pressure, with no guaranteed minimum resources.

---

## 5. How to See ACTUAL Resource Usage from kubectl

### Command 1: `kubectl top nodes` — Real-Time Node Usage

```bash
kubectl top nodes
```

Output:

```
NAME                                    CPU(cores)   CPU%   MEMORY(bytes)   MEMORY%
aks-bssdevusr02-31789595-vmss000000     2100m        26%    28500Mi         93%
```

This shows **actual consumption**, not requests. It requires the Metrics Server to be installed (it is by default on AKS).

### Command 2: `kubectl top pods` — Real-Time Pod Usage

```bash
# All pods on the node, sorted by memory
kubectl top pods --all-namespaces --sort-by=memory | head -30

# Specific namespace
kubectl top pods -n b2b-bss-dev-be --sort-by=memory

# Specific pod
kubectl top pod admin-service-ccf6776b7-g66pb -n b2b-bss-dev-be
```

This is the **most important command** for your situation — it tells you how much each pod is actually consuming, which you can then use to set proper requests.

### Command 3: Compare Requests vs Actual

```bash
# Show requests alongside actual usage for a namespace
kubectl top pods -n b2b-bss-dev-be --no-headers | while read line; do
  POD=$(echo $line | awk '{print $1}')
  echo "$line | Requests: $(kubectl get pod $POD -n b2b-bss-dev-be -o jsonpath='{.spec.containers[0].resources.requests.memory}')"
done
```

---

## 6. Recommended Tools (Beyond kubectl)

### Tool 1: K9s (Highly Recommended)

**K9s** is a terminal-based UI for Kubernetes. It gives you a real-time, interactive dashboard.

**Install:**

```bash
# macOS
brew install derailed/k9s/k9s

# Linux
curl -sS https://webinstall.dev/k9s | bash

# Windows
choco install k9s
```

**Key views for resource monitoring:**

|Shortcut|View|What It Shows|
|---|---|---|
|`:node`|Node list|Real CPU/memory usage per node|
|`:pod`|Pod list|Live CPU/memory per pod|
|`:top node`|Node top|Like `kubectl top nodes` but live|
|`:top pod`|Pod top|Like `kubectl top pods` but live|
|`shift+e` on any pod|Resource extender|Shows requests vs limits vs actual|

K9s color-codes pods that are over their limits or have no requests — making it immediately obvious which pods need attention.

### Tool 2: Prometheus + Grafana (You Already Have This)

You already have Prometheus and Grafana deployed in the `observability` namespace. Use these queries:

**Actual memory usage vs requests:**

```promql
# Actual container memory usage
container_memory_working_set_bytes{node="aks-bssdevusr02-31789595-vmss000000"}

# Requested memory
kube_pod_container_resource_requests{resource="memory", node="aks-bssdevusr02-31789595-vmss000000"}

# Pods using more memory than requested (the dangerous ones)
(container_memory_working_set_bytes{node="aks-bssdevusr02-31789595-vmss000000"} 
  - on(pod, container) kube_pod_container_resource_requests{resource="memory"}) > 0
```

**CPU usage vs requests:**

```promql
# Actual CPU usage rate
rate(container_cpu_usage_seconds_total{node="aks-bssdevusr02-31789595-vmss000000"}[5m])

# Requested CPU
kube_pod_container_resource_requests{resource="cpu", node="aks-bssdevusr02-31789595-vmss000000"}
```

### Tool 3: Kubernetes VPA (Vertical Pod Autoscaler) in Recommendation Mode

VPA can analyze your pods and recommend correct request/limit values without changing anything.

```yaml
apiVersion: autoscaling.k8s.io/v1
kind: VerticalPodAutoscaler
metadata:
  name: admin-service-vpa
  namespace: b2b-bss-dev-be
spec:
  targetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: admin-service
  updatePolicy:
    updateMode: "Off"  # Only recommend, don't auto-apply
```

After a few days, check recommendations:

```bash
kubectl get vpa admin-service-vpa -n b2b-bss-dev-be -o yaml
```

### Tool 4: kubectl-resource-view Plugin

```bash
# Install via krew
kubectl krew install resource-capacity

# Show actual vs requested per node
kubectl resource-capacity --util --sort memory.util

# Output:
# NODE                          CPU REQ   CPU LIMIT   CPU UTIL   MEM REQ    MEM LIMIT   MEM UTIL
# aks-bssdevusr02-...000000     4744m     7710m       2100m      18751Mi    33675Mi     28500Mi
```

This is the single best command for seeing the gap between requests and reality.

---

## 7. The Solution — Step by Step

### Step 1: Audit Actual Usage (Do This Now)

```bash
# Get actual usage for all pods with no requests
kubectl top pods --all-namespaces --no-headers | sort -k3 -rn | head -40
```

### Step 2: Set Resource Requests on All Pods

For every pod currently showing `0 (0%)`, add resource requests based on actual usage. Example:

```yaml
# Before (dangerous)
spec:
  containers:
  - name: admin-service
    image: admin-service:latest
    # No resources defined!

# After (correct)
spec:
  containers:
  - name: admin-service
    image: admin-service:latest
    resources:
      requests:
        cpu: "100m"
        memory: "256Mi"
      limits:
        cpu: "500m"
        memory: "512Mi"
```

**Rule of thumb**: Set requests to ~80% of observed average usage, and limits to ~150% of observed peak usage.

### Step 3: Consider Splitting Workloads Across Nodes

Your single node is running 62 pods including a full observability stack. Consider:

- Moving the observability stack (Prometheus, Grafana, Loki) to a **dedicated node pool**
- Using **node affinity** or **taints/tolerations** to separate application and infrastructure workloads
- Adding a second node to the `bssdevusr02` pool

### Step 4: Set Up Proper Alerting

Create alerts for when actual usage diverges from requests:

```yaml
# PrometheusRule - Alert when a pod uses 2x its memory request
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: resource-alerts
spec:
  groups:
  - name: resource-usage
    rules:
    - alert: PodMemoryExceedsRequest
      expr: |
        container_memory_working_set_bytes
        / on(pod, container) kube_pod_container_resource_requests{resource="memory"}
        > 2
      for: 10m
      labels:
        severity: warning
      annotations:
        summary: "Pod {{ $labels.pod }} using >2x its memory request"
    - alert: NodeMemoryHigh
      expr: |
        (1 - node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes) > 0.90
      for: 5m
      labels:
        severity: critical
      annotations:
        summary: "Node {{ $labels.instance }} memory usage above 90%"
```

### Step 5: Enforce Resource Policies with LimitRange

Prevent future deployments from having zero requests:

```yaml
apiVersion: v1
kind: LimitRange
metadata:
  name: default-resources
  namespace: b2b-bss-dev-be
spec:
  limits:
  - default:
      cpu: "200m"
      memory: "256Mi"
    defaultRequest:
      cpu: "50m"
      memory: "128Mi"
    type: Container
```

Apply this to each namespace to ensure every new pod gets at least a minimum request.

---

## 8. Quick Reference — Which Tool for Which Question

|Question|Tool|Command/Action|
|---|---|---|
|How much memory is **actually free** on the node?|`kubectl top nodes` or Azure Monitor|`kubectl top nodes`|
|How much memory is each **pod actually using**?|`kubectl top pods` or K9s|`kubectl top pods -A --sort-by=memory`|
|How much memory has the **scheduler reserved**?|`kubectl describe node`|Check "Allocated resources" section|
|Which pods have **no resource requests**?|kubectl or K9s|`kubectl get pods -A -o json \| jq ...`|
|What **should** my requests be set to?|VPA or Prometheus|Deploy VPA in recommendation mode|
|Real-time interactive monitoring?|**K9s**|`:top pod`, `:top node`|
|Historical trends and dashboards?|**Grafana + Prometheus**|Use built-in dashboards|
|Side-by-side requests vs actual?|**kubectl resource-capacity**|`kubectl resource-capacity --util`|

---

## 9. Summary

The discrepancy between Azure Monitor (3 GB free) and kubectl (62% reserved) is caused by **pods without resource requests**. Kubernetes doesn't know about their consumption, but the OS does.

**Immediate actions:**

1. Run `kubectl top pods -A --sort-by=memory` to see real usage
2. Set resource requests on all 45+ pods that currently have none
3. Consider separating your observability stack to its own node pool
4. Deploy LimitRange to prevent zero-request pods in the future
5. Install K9s for day-to-day monitoring