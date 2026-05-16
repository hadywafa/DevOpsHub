# Loki Canary

## Overview

> Loki Canary is a **standalone app** that audits the **log-capturing performance of a Grafana Loki cluster**.
>
> This component **emits and periodically** queries for logs,**making sure that Loki is ingesting logs without any data loss**. When something is wrong with Loki, the Canary often provides the first indication.
>
> - Loki Canary generates artificial log lines.
> - These log lines are sent to the Loki cluster.
> - Loki Canary communicates with the Loki cluster to capture metrics about the artificial log lines, such that Loki Canary forms information about the performance of the Loki cluster.
> - The information is available as Prometheus time series metrics.

## References

- [Audit data propagation latency and correctness using Loki Canary](https://grafana.com/docs/loki/latest/operations/loki-canary/)
