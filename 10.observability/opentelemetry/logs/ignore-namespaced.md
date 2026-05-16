Yes — but **how** you “limit by namespace” depends on *where you filter*.

You have 3 practical options (ranked by what actually works in production):

---

## Option 1 (best): Collect everything, then **filter by `k8s.namespace.name`** in the Collector

Because the DaemonSet reads `/var/log/containers/*.log` (node-level), it will see all pods. The correct way to restrict is:

1. Enrich logs with `k8sattributes` (so each log has namespace/pod/container)
2. Drop everything not in your allowed namespaces using `filter` (OTTL)

### Example pipeline (allow only specific namespaces)

```yaml
processors:
  k8sattributes:
    auth_type: serviceAccount
    extract:
      metadata:
        - k8s.namespace.name
        - k8s.pod.name
        - k8s.container.name
        - k8s.node.name

  filter/only_namespaces:
    error_mode: ignore
    logs:
      log_record:
        - 'attributes["k8s.namespace.name"] != "prod" and attributes["k8s.namespace.name"] != "observability"'

  batch: {}

service:
  pipelines:
    logs:
      receivers: [filelog]
      processors: [k8sattributes, filter/only_namespaces, batch]
      exporters: [loki]
```

✅ This means: **drop** any log record whose namespace is not `prod` or `observability`.

> If you want the opposite (exclude some namespaces), just invert the condition.

---

## Option 2: Use `include` patterns in `filelog` to match only namespaces (works but brittle)

Container log filenames usually include namespace/pod/container, like:
`<pod>_<namespace>_<container>-<containerid>.log`

So you *can* do:

```yaml
receivers:
  filelog:
    include:
      - /var/log/containers/*_prod_*.log
      - /var/log/containers/*_observability_*.log
```

This is fast and simple.

⚠️ Why it’s brittle:

* naming format can differ across runtimes/distributions
* you still probably want `k8sattributes` for labels

---

## Option 3: Filter in Loki (not recommended as the primary control)

You can push everything and then control retention/queries by namespace in Loki.

But you’ll still pay:

* network
* ingestion
* storage
* index cost

So it’s not a real “collect only”; it’s “store everything then ignore”.

---

# Recommendation for you

Use **Option 1** (k8sattributes + filter). It’s stable, explicit, and independent of filename formats.

If you tell me the namespaces you want to **include** (or exclude), I’ll write the exact OTTL filter expression for your list.
