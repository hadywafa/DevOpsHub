```yaml
# alertmanager.yaml
# ✅ Final, production-grade baseline for Kubernetes + Azure Logic App (webhook)
# Assumes your Prometheus alert rules set (at least): severity, cluster, namespace, service, env, team
# Optional label: notify=page|notify|drop (recommended)

global:
  resolve_timeout: 5m

route:
  receiver: "logicapp"
  # Use stable labels to avoid spam (dedupe/grouping)
  group_by: ["alertname", "cluster", "env", "namespace", "service", "severity"]
  group_wait: 30s
  group_interval: 5m
  repeat_interval: 12h

  # Child routes override defaults (repeat_interval, drop, etc.)
  routes:
    # 1) Hard drop anything explicitly marked as drop
    - matchers:
        - notify="drop"
      receiver: "null"

    # 2) Page-worthy alerts (critical / page)
    # If you don't use notify, keep severity=critical only.
    - matchers:
        - notify="page"
      receiver: "logicapp"
      repeat_interval: 1h

    - matchers:
        - severity="critical"
      receiver: "logicapp"
      repeat_interval: 1h

    # 3) Warnings: less frequent reminders
    - matchers:
        - severity="warning"
      receiver: "logicapp"
      repeat_interval: 12h

    # 4) Info: very low reminder frequency (or route to null if you prefer)
    - matchers:
        - severity="info"
      receiver: "logicapp"
      repeat_interval: 24h

inhibit_rules:
  # If a critical alert exists for same service scope, suppress warning/info versions
  - source_matchers:
      - severity="critical"
    target_matchers:
      - severity=~"warning|info"
    equal: ["alertname", "cluster", "env", "namespace", "service"]

  # Optional: if you use notify label, page suppresses notify-only
  - source_matchers:
      - notify="page"
    target_matchers:
      - notify="notify"
    equal: ["alertname", "cluster", "env", "namespace", "service"]

receivers:
  - name: "logicapp"
    webhook_configs:
      - url: "https://<YOUR-LOGIC-APP-TRIGGER-URL>"
        send_resolved: true
        max_alerts: 0
        # If your Logic App endpoint requires auth, use one of these patterns:
        # (A) Put the auth in the Logic App trigger URL (SAS-style query string) ✅ most common
        # (B) Or use http_config below if you have a bearer token / basic auth
        # http_config:
        #   bearer_token: "<TOKEN>"
        #   tls_config:
        #     insecure_skip_verify: false

  - name: "null"
```

### What you must enforce in Prometheus alert rules (so this config works well)

Use these labels in alerts (stable + routable):

* `severity`: `critical|warning|info`
* `cluster`, `env`, `namespace`, `service`, `team`
* optional `notify`: `page|notify|drop`

Example label block in a Prometheus rule:

```yaml
labels:
  severity: critical
  notify: page
  team: platform
  env: preprod
  service: api
  cluster: aks-preprod
```

### Who “wins” when all are together?

* **Silence** (runtime) wins first → no notification at all.
* Then Alertmanager applies **grouping/dedup** automatically.
* Then **repeat_interval** triggers reminders while still firing.

If you paste your current alert labels (one real firing alert from Prometheus `/alerts`), I can adjust `group_by` to match your label reality (so you don’t accidentally group everything together or explode into per-pod spam).
