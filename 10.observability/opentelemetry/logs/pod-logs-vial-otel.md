# Pods Logs


```yaml

apiVersion: opentelemetry.io/v1beta1
kind: OpenTelemetryCollector
metadata:
  name: otel-logs
  namespace: observability
spec:
  mode: daemonset
  image: otel/opentelemetry-collector-contrib:latest

  volumeMounts:
    - name: varlogcontainers
      mountPath: /var/log/containers
      readOnly: true
    - name: varlogpods
      mountPath: /var/log/pods
      readOnly: true

  volumes:
    - name: varlogcontainers
      hostPath:
        path: /var/log/containers
    - name: varlogpods
      hostPath:
        path: /var/log/pods

  config:
    receivers:
      filelog:
        include:
          - /var/log/containers/*.log
        start_at: end

        # CRI container log parsing (so you get timestamp/stream/attrs correctly)
        operators:
          - type: container

          # ✅ Multiline for Java stack traces:
          # join lines until we see a "new log line start"
          # This pattern is common: timestamp at line start.
          - type: recombine
            combine_field: body
            source_identifier: attributes["log.file.path"]
            is_first_entry: 'body matches "^[0-9]{4}-[0-9]{2}-[0-9]{2}[ T][0-9]{2}:[0-9]{2}:[0-9]{2}"'
            max_unmatched_batch_size: 1000

    processors:
      k8sattributes:
        auth_type: serviceAccount
        extract:
          metadata:
            - k8s.namespace.name
            - k8s.pod.name
            - k8s.container.name
            - k8s.node.name
        passthrough: false

      batch: {}

    exporters:
      # Option A: send logs to Loki via OTLP gateway (Grafana Alloy / Loki gateway)
      otlphttp:
    #   endpoint: http://alloy.observability.svc:4318
        endpoint: http://loki-gateway.observability.svc:4318
        tls:
          insecure: true

      # Option B (if you use Loki exporter directly):
      # loki:
      #   endpoint: http://loki-gateway.observability.svc:3100/loki/api/v1/push

    service:
      pipelines:
        logs:
          receivers: [filelog]
          processors: [k8sattributes, batch]
          exporters: [otlphttp]
```