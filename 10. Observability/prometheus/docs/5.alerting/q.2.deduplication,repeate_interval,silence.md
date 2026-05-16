Here’s the **real difference** between **Deduplication**, **Silences**, and **Repeat notifications** in Alertmanager—simplified, with configs + best practices.

---

# 1) ✅ Deduplication = “Don’t spam me with the same alert again and again”

### What it is

If the **same alert instance** (same labels = same fingerprint) keeps firing, Alertmanager will **not send a new notification every time Prometheus re-sends it**.

Prometheus keeps pushing alerts repeatedly while firing. **Deduplication prevents duplicates**.

### Example (what would be deduped)

Same alert:

```yaml
alertname="HighErrorRate"
namespace="payments"
service="api"
severity="page"
```

If it’s still firing after 5 minutes, Prometheus sends again → **Alertmanager dedupes** → no new message (unless repeat_interval triggers, explained later).

### How to “configure” dedupe

Deduplication is largely **automatic**, but it depends on:

* **group_by** (how alerts are grouped into one notification)
* **labels** included (don’t include volatile labels)

**Bad practice (breaks dedupe)**
Including changing labels like `pod`, `instance`, `container`, `request_id` in the alert identity or grouping. You’ll get “new” alerts constantly.

**Good practice**
Group by stable “service-level” dimensions.

```yaml
route:
  group_by: ['alertname', 'cluster', 'namespace', 'service', 'severity']
```

✅ Result: one message “HighErrorRate service=api” instead of 50 messages (one per pod).

---

# 2) 🔇 Silences = “Mute alerts that match a filter (maintenance window)”

### What it is

A **Silence** is a temporary rule inside Alertmanager that says:

> “If labels match X, do not notify.”

This is used for:

* planned maintenance
* noisy known issue
* deployments
* migrations

### Important

Silence **does not stop the alert from firing** in Prometheus.
It only stops **notifications**.

### Example: Silence all paging alerts for payments namespace

A silence match like:

* `namespace="payments"`
* `severity="page"`

Then everything matching is muted.

### How to configure Silences

Silences are usually created via:

* Alertmanager UI
* amtool CLI
* Alertmanager API

Example using **amtool**:

```bash
amtool silence add namespace="payments" severity="page" \
  --comment="Payments maintenance" \
  --duration="2h"
```

### Best practice for Silences

✅ Silence **by stable labels**: `cluster, env, namespace, service`
❌ Don’t silence by `pod` unless you really mean it.

✅ Add `runbook_url` + good alert labels, so silencing is easy:

```yaml
labels:
  severity: page
  service: api
  team: backend
  env: preprod
annotations:
  runbook_url: "https://runbooks.mycompany.com/api/higherrorrate"
```

---

# 3) 🔁 Repeat notifications = “Remind me if it’s still broken”

### What it is

Even with dedupe, Alertmanager can re-send a reminder:

> “This alert is still firing.”

This is controlled by **repeat_interval**.

### Example

* Alert fires at 10:00 → notify
* Still firing at 14:00 → notify again (repeat reminder)
* Still firing at 18:00 → notify again

### Configuration example

```yaml
route:
  receiver: default
  group_by: ['alertname', 'cluster', 'namespace', 'service', 'severity']
  group_wait: 30s
  group_interval: 5m
  repeat_interval: 4h
receivers:
- name: default
  webhook_configs:
  - url: http://my-webhook
```

### Best practice for repeat_interval

* **Paging / critical**: 30m – 2h (depends on on-call policy)
* **Warning**: 4h – 24h
* **Info**: often disable by setting very high or route elsewhere

---

# 4) The easiest way to remember the differences

| Feature                  | What it solves                 | Where it applies | Typical use                              |
| ------------------------ | ------------------------------ | ---------------- | ---------------------------------------- |
| **Deduplication**        | prevents identical duplicates  | automatic        | Prometheus keeps resending firing alerts |
| **Silences**             | mute notifications temporarily | manual/API/UI    | maintenance window / known noisy         |
| **Repeat notifications** | reminder if still firing       | route config     | keep pressure on unresolved incidents    |

---

# 5) Practical “real company” example config (good defaults)

```yaml
route:
  receiver: "slack-warning"
  group_by: ['alertname', 'cluster', 'namespace', 'service', 'severity']
  group_wait: 30s
  group_interval: 5m
  repeat_interval: 12h

  routes:
  - matchers:
    - severity="page"
    receiver: "oncall"
    repeat_interval: 1h

  - matchers:
    - severity="info"
    receiver: "null"   # drop noise (or send to low-priority channel)

receivers:
- name: "slack-warning"
  slack_configs:
  - channel: "#alerts-warning"

- name: "oncall"
  webhook_configs:
  - url: "http://pagerduty-webhook"

- name: "null"
```

---

# 6) Best practices checklist (the “don’t regret later” list)

✅ **Alert labels must include**: `severity`, `service`, `namespace`, `cluster`, `team`, `env`
✅ **Avoid volatile labels**: `pod`, `instance`, `container` in grouping (unless needed)
✅ Set sensible **repeat_interval** by severity
✅ Use **Silences** for maintenance, not permanent muting
✅ Put `runbook_url` in annotations so on-call can act fast
✅ Have one “null receiver” for info/noise

---

If you tell me what receiver you’re using (Azure Logic App webhook / Teams / Slack) and your desired behavior (send *everything* or only page+warn), I’ll write you a **ready-to-apply Alertmanager YAML** with **clean grouping + dedupe + repeat rules** for your exact labels (AKS, namespace, cluster, etc.).
