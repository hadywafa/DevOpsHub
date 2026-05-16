In Prometheus/Alertmanager, **`severity` is not a built-in enum**. It’s **just a label key** you (or your org) define, and the “types” are **any string values** you choose.

What matters is consistency, because Alertmanager routing usually matches on it:

```yaml
- matchers:
  - severity="page"
```

So yes — it can be **any name**, but you should pick a small, standard set.

---

## Common “severity” schemes used in real setups

### Option A) Simple + practical (most Kubernetes teams)

* `severity: info`
* `severity: warning`
* `severity: critical`

✅ Easy, widely understood.

### Option B) On-call driven (very common with PagerDuty/Opsgenie)

* `severity: page`   (wakes someone up)
* `severity: ticket` (create incident/ticket, not wake up)
* `severity: warn`   (Slack/Teams channel)
* `severity: info`   (low priority / drop)

✅ Maps directly to routing destinations.

### Option C) SRE-style numeric (less friendly, but common in ITIL)

* `severity: sev1` (critical outage)
* `severity: sev2`
* `severity: sev3`
* `severity: sev4`

✅ Good when you already use Sev levels in incident process.

---

## What I recommend (for your “send all alerts to Logic App” world)

Use **two labels** (clean and scalable):

1. `severity`: how bad it is (business impact)

* `critical`, `warning`, `info`

2. `notify`: what action to take (notification policy)

* `page`, `notify`, `drop`

Example:

```yaml
labels:
  severity: critical
  notify: page
```

Then in Alertmanager routes:

```yaml
routes:
- matchers: ['notify="page"']
  receiver: "logicapp-page"
  repeat_interval: 1h

- matchers: ['notify="notify"']
  receiver: "logicapp-notify"
  repeat_interval: 12h

- matchers: ['notify="drop"']
  receiver: "null"
```

This avoids mixing “impact” (severity) with “how to notify” (policy).

---

## Where you set severity?

In the **Prometheus alert rule** (labels):

```yaml
- alert: PodCrashLooping
  expr: ...
  for: 5m
  labels:
    severity: warning
    team: platform
```

Or you can add/overwrite in Alertmanager via relabeling (less common). Most teams set it in the rule.

---

## Best practice rules

* Keep values **few and consistent** (3–5 max).
* Don’t use random spellings (`WARN`, `Warning`, `warn`) → pick one style.
* Use the same severity model across all teams (or at least within a cluster).
* Add `team`, `service`, `env`, `cluster` labels too—severity alone isn’t enough for routing.

If you tell me what notification destinations you have (Logic App only? plus Teams/Slack?), I’ll suggest the best severity+policy naming that fits that exact routing.
