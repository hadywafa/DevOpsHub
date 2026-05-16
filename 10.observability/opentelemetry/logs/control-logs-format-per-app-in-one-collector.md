You can do **either**, but the “right” design in Kubernetes is:

✅ **One log collector (DaemonSet) per node** for all pods
✅ **Different parsing/multiline rules per app** inside that one collector (routing)

So: **don’t deploy multiple collectors just because formats differ**. Use one collector and **apply different operators conditionally**.

---

# The key concept

You have 2 choices:

## Option A) One `filelog` receiver, *route by app*, apply different pipelines/operators

Best balance: one agent, multiple “parsing branches”.

### How it works

* Read all files
* Add k8s metadata (namespace/pod/container labels)
* Route logs to different pipelines based on attributes (e.g., `k8s.container.name`, `service.name`, namespace labels)
* Each pipeline has its own multiline/parser

## Option B) Multiple `filelog` receivers (each has its own include/exclude + operators)

Also works, often simpler to reason about:

* receiver for Java backend (multiline stacktrace)
* receiver for Nginx/Frontend (JSON or combined format)
* receiver for “everything else” (no multiline)

Still **one collector**, just multiple receivers.

---

# What you should NOT do

❌ One global multiline rule for all logs
Because multiline rules are **format-specific**. A Java stacktrace recombine rule can break JSON logs (or vice versa).

---

# Recommended: One collector + multiple receivers (simple + safe)

This is the cleanest approach for “multiple apps, different formats”.

### Example

* Java backend: recombine stack traces
* Frontend (nginx / node): parse JSON (no multiline)
* Default: just parse CRI

```yaml
receivers:
  # 1) Java apps (stack traces)
  filelog/java:
    include:
      - /var/log/containers/*backend*_*_*.log
      - /var/log/containers/*spring*_*_*.log
    start_at: end
    operators:
      - type: container
      - type: recombine
        id: java_multiline
        combine_field: body
        source_identifier: attributes["log.file.path"]
        is_first_entry: 'body matches "^[0-9]{4}-[0-9]{2}-[0-9]{2}" or body matches "^(INFO|WARN|ERROR|DEBUG|TRACE)\\b"'
        max_log_size: 1048576
        timeout: 2s

  # 2) Frontend apps (JSON logs)
  filelog/frontend:
    include:
      - /var/log/containers/*frontend*_*_*.log
      - /var/log/containers/*nginx*_*_*.log
    start_at: end
    operators:
      - type: container
      - type: json_parser
        parse_from: body

  # 3) Catch-all (no fancy parsing)
  filelog/default:
    include:
      - /var/log/containers/*.log
    exclude:
      - /var/log/containers/*backend*_*_*.log
      - /var/log/containers/*spring*_*_*.log
      - /var/log/containers/*frontend*_*_*.log
      - /var/log/containers/*nginx*_*_*.log
    start_at: end
    operators:
      - type: container
```

Then send all to same exporter:

```yaml
service:
  pipelines:
    logs/java:
      receivers: [filelog/java]
      processors: [batch]
      exporters: [otlphttp/loki]

    logs/frontend:
      receivers: [filelog/frontend]
      processors: [batch]
      exporters: [otlphttp/loki]

    logs/default:
      receivers: [filelog/default]
      processors: [batch]
      exporters: [otlphttp/loki]
```

✅ This gives you **format control per “app group”** without multiple collectors.

---

# How to control “per app” correctly (better than filename matching)

Filename matching (`*backend*`) works but is brittle.

Better routing keys:

* `k8s.namespace.name`
* `k8s.pod.name`
* `k8s.container.name`
* pod labels like `app.kubernetes.io/name`

To do that reliably, enrich logs with `k8sattributes` processor (API-based).

Then you can route based on pod labels instead of guessing by file name.

---

# When to use separate collectors?

Only in special cases:

* strict isolation/security boundaries (different tenants/namespaces)
* different export destinations (some logs to Loki, some to Splunk)
* heavy parsing CPU cost that you want to isolate

Otherwise, one DaemonSet collector is the standard.

---

## Practical recommendation for you

Start with **multiple receivers** (Option B). It’s easiest, predictable, and you can grow it later into fancy routing.

If you paste the list of your apps (namespaces + pod/container names + which ones are Java stack traces vs JSON), I’ll write you a clean receiver split + include/exclude patterns that won’t overlap and won’t break logs.
