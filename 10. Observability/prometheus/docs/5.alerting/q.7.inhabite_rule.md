# **`inhibit_rules` (inhibition rules)** in Alertmanager are a noise-reduction feature .

They tell Alertmanager:

> “If a **more important** alert is firing, **suppress notifications** for other related alerts.”

Key point: **suppressed alerts are still firing** (you’ll still see them in Prometheus/Alertmanager UI), but **Alertmanager won’t notify** for them while the inhibition condition holds.

---

## Why it exists (simple example)

If your database is down, you might get:

- `DatabaseDown` (critical)
- 20 other alerts like `ApiHighLatency`, `ApiErrorRate`, `WorkerQueueBacklog` (warnings) caused by the DB outage

Inhibition lets you say:

- “When `DatabaseDown` is firing, don’t notify the 20 dependent warning alerts.”

✅ You get **one clear root-cause page**, not a notification storm.

---

## How it works (the mechanism)

An inhibition rule has:

- **source_matchers**: the “big/boss” alert (the one that suppresses others)
- **target_matchers**: the alerts to be suppressed
- **equal**: labels that must match between source and target (so you only suppress related alerts)

### Example inhibition rule

```yaml
inhibit_rules:
  - source_matchers:
      - severity="critical"
    target_matchers:
      - severity=~"warning|info"
    equal: ["cluster", "env", "namespace", "service"]
```

Meaning:

- If a **critical** alert is firing for a given `cluster/env/namespace/service`,
- Then suppress **warning/info** alerts for the same scope.

---

## Important distinctions (don’t confuse them)

### Inhibition vs Silence

- **Inhibition**: automatic suppression based on another firing alert.
- **Silence**: manual suppression based on matchers + time window (maintenance).

### Inhibition vs Deduplication

- **Dedup**: don’t send the same alert notification repeatedly.
- **Inhibition**: don’t send _different_ alerts because a “parent” alert is already firing.

---

## What “wins”?

1. **Silence** wins (if silenced → nothing notifies)
2. Then **Inhibition** (suppresses targets while source is firing)
3. Then **Dedup + grouping**
4. Then **repeat_interval** reminders (only for alerts not silenced/inhibited)

---

## Best practices for inhibition rules

✅ Inhibit only when you truly have a “root cause” alert
Examples of good “source” alerts:

- `KubeNodeNotReady` or `KubeletDown`
- `DatabaseDown`
- `IngressControllerDown`
- `ClusterAPIUnavailable`

✅ Make `equal` use _stable, scoping labels_:

- `cluster`, `env`, `namespace`, `service`
  Avoid: `pod`, `instance` (too granular)

✅ Don’t over-inhibit
If you inhibit too broadly, you can hide meaningful signals.

---

## How to validate inhibition is working

In Alertmanager UI:

- Go to **Alerts**
- An inhibited alert will show as **“Inhibited”** (depends on UI version)
- You’ll see the firing alert but it won’t notify.

Or via `amtool`:

```bash
amtool --alertmanager.url=http://localhost:9093 alert
```

---

If you show me 2–3 real alerts you get during incidents (labels included), I can write a **safe inhibition policy** that reduces noise without hiding important signals.
