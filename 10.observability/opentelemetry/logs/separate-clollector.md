Got it — Loki **gateway on port 3000** is very common (Grafana’s “loki-gateway” Service often fronts Loki with nginx and exposes **/loki/api/v1/push** and sometimes OTLP endpoints depending on chart).

I’ll answer in 3 parts:

1. **What `container` + `recombine` operators actually do**
2. **How to export to `loki-gateway:3000` correctly**
3. **How to collect PVC file logs without sidecar (separate Pod)** — with the *realistic constraints* and the best pattern that won’t risk your “important app”.

---

## 1) What does this do?

### `- type: container`

This is a **log parsing operator** for Kubernetes container runtime logs (CRI / Docker JSON).

**What it does:**

* Reads each line from `/var/log/containers/*.log`
* Parses the container log wrapper format into fields like:

  * timestamp
  * stream (`stdout` / `stderr`)
  * actual log message (becomes the `body`)
* So instead of shipping the raw CRI line, you ship a clean structured record.

✅ Without it you’ll often see the CRI wrapper inside the message, and timestamps might be wrong.

---

### `- type: recombine` (multiline join)

Java exceptions are **multiple lines** but file tailing reads **line by line**.

So without recombine:

* line 1 (“Exception in thread…”) goes as one log record
* stack trace lines become separate log records
* some pipelines/backends show only first line or “lose” context

**What recombine does:**

* It buffers lines and **merges them into one single log record**
* It uses `is_first_entry` to detect “this is the start of a new log event”
* Everything after that is appended until the next “first entry” appears

Your rule:

```yaml
is_first_entry: 'body matches "^[0-9]{4}-[0-9]{2}-[0-9]{2}[ T][0-9]{2}:[0-9]{2}:[0-9]{2}"'
```

Meaning:

* “If a line starts with a timestamp like `2026-02-07 12:34:56` or `2026-02-07T12:34:56` → it’s a new log entry”
* Otherwise (like `at com.foo.Bar(Bar.java:12)`), it’s part of the previous entry

`source_identifier: attributes["log.file.path"]` means:

* Keep multiline buffering **per file** (per container log file), so logs from different pods/containers don’t get mixed.

`max_unmatched_batch_size: 1000`

* Safety cap: if it never finds a “first entry” again, don’t buffer forever.

✅ This is exactly what you need for Java stack traces.

---

## 2) Export to Loki Gateway on port 3000

You have **two valid ways**:

### Option A) Use the OTel **Loki exporter** (push API)

This sends to:
`http://loki-gateway:3000/loki/api/v1/push`

Example:

```yaml
exporters:
  loki:
    endpoint: http://loki-gateway.observability.svc.cluster.local:3000/loki/api/v1/push
```

This is the most direct Loki-native path.

---

### Option B) Use **OTLP HTTP** to Loki Gateway (ONLY if your gateway supports OTLP)

Some setups (Grafana Alloy / OTEL gateway) expose OTLP endpoints, but **Loki itself** is not “OTLP-native” unless there’s a translator component in front.

So **don’t assume** `http://loki-gateway:3000/v1/logs` works unless you know you enabled an OTLP receiver there.

✅ So for “loki-gateway:3000” the safest is **Option A (loki exporter)**.

---

## 3) PVC file logs without sidecar (separate Pod)

You said: “don’t use sidecar, app is important; run separate pod”.

### Reality check (important)

A separate pod can read those files **only if it can mount the same PVC**.

That means:

* PVC must support being mounted by two pods at the same time.
* If your PVC is **ReadWriteOnce (RWO)** (most block storage), then **you cannot mount it in another pod while the app is using it**.
* If your PVC is **ReadWriteMany (RWX)** (NFS / Azure Files / CephFS), then it’s fine.

So:

✅ If RWX → separate “log collector pod” works perfectly.
❌ If RWO → you can’t mount it concurrently. You must either:

* use sidecar (safest and common), **or**
* ship logs from inside the app container using an agent, **or**
* push logs to stdout and collect normally, **or**
* use a storage-level method (NFS server side, object storage, etc.)

You asked for “separate pod” — I’ll give you that solution (works when RWX, and also works if the app is the *only* pod using it at the time).

---

### Separate Pod OTel Collector reading the PVC

**Concept**

* Create a Deployment in observability namespace
* Mount the PVC read-only
* Use `filelog` receiver to tail `/u01/oracle/logs/ATG_SERVICE.log*`
* Export to Loki gateway

**Example manifest (Deployment)**

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: otel-pvc-log-reader
  namespace: observability
spec:
  replicas: 1
  selector:
    matchLabels:
      app: otel-pvc-log-reader
  template:
    metadata:
      labels:
        app: otel-pvc-log-reader
    spec:
      containers:
        - name: otelcol
          image: otel/opentelemetry-collector-contrib:latest
          args: ["--config=/conf/config.yaml"]
          volumeMounts:
            - name: otel-config
              mountPath: /conf
            - name: atg-logs
              mountPath: /u01/oracle/logs
              readOnly: true
          resources:
            requests:
              cpu: 100m
              memory: 200Mi
            limits:
              cpu: 500m
              memory: 800Mi
      volumes:
        - name: otel-config
          configMap:
            name: otel-pvc-log-reader-config
        - name: atg-logs
          persistentVolumeClaim:
            claimName: YOUR_ATG_PVC_NAME
```

And the ConfigMap:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: otel-pvc-log-reader-config
  namespace: observability
data:
  config.yaml: |
    receivers:
      filelog:
        include:
          - /u01/oracle/logs/ATG_SERVICE.log*
        start_at: end
        operators:
          # optional: if lines include a timestamp at start
          - type: recombine
            combine_field: body
            source_identifier: attributes["log.file.path"]
            is_first_entry: 'body matches "^[0-9]{4}-[0-9]{2}-[0-9]{2}[ T][0-9]{2}:[0-9]{2}:[0-9]{2}"'
            max_unmatched_batch_size: 2000

    processors:
      batch: {}

    exporters:
      loki:
        endpoint: http://loki-gateway.observability.svc.cluster.local:3000/loki/api/v1/push
        # optional labels to make querying easier
        labels:
          attributes:
            log.file.name: "filename"

    service:
      pipelines:
        logs:
          receivers: [filelog]
          processors: [batch]
          exporters: [loki]
```

### Why this will NOT “destroy the app pod”

* It’s an independent Deployment
* It only mounts the PVC read-only
* It doesn’t touch the app container
* The only “risk” is storage mount rules (RWO vs RWX)

---

## Critical: check your PVC access mode

Run:

```bash
kubectl get pvc YOUR_ATG_PVC_NAME -n <app-namespace> -o yaml | grep -A3 accessModes
```

If you see:

* `ReadWriteMany` ✅ you’re good.
* `ReadWriteOnce` ❌ cannot mount into the collector pod concurrently.

If it’s RWO but you still want “separate pod”, tell me:

* Storage class name
* Cloud/on-prem (EKS/EBS? AKS/Azure Disk? NFS? Ceph?)
  And I’ll give you the best non-sidecar alternative that still gets those file logs reliably (usually: redirect file logs to stdout, or ship with a lightweight file forwarder inside the same pod but isolated, or switch to RWX).

---

## Export endpoint summary for your case (port 3000)

Use this:

* `http://loki-gateway.<ns>.svc.cluster.local:3000/loki/api/v1/push`

That’s Loki Push API; it should work in almost all “loki-gateway” setups.

If you paste your `kubectl get svc loki-gateway -n observability -o yaml` I can confirm the exact service name/port mapping and whether OTLP is supported or not.
