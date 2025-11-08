# Prometheus in K8s

![1762593193329](image/x/1762593193329.png)

- cluster metrics via `kube-state-metrics`

![1762593459327](image/x/1762593459327.png)

- node metrics via `node_exporter`

![1762593520423](image/x/1762593520423.png)

## service discovery

![1762595244914](image/x/1762595244914.png)

## How to Deploy

![1762595306205](image/x/1762595306205.png)

- Repository: prometheus-community
- Chart: kube-prometheus-stack
- [Prometheus Helm Chart Link](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack)

## How kube-prometheus-stack works

![1762595638619](image/x/1762595638619.png)

![1762595741202](image/x/1762595741202.png)

---

---

### Install Prometheus Helm Chart

```sh
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm install prometheus prometheus-community/kube-prometheus-stack
```

## Prometheus Chart Components

...

## Additional Scrape Configs in values.yaml

```yaml
# additionalScrapeConfigs:
# - job_name: 'prometheus'
#   scrape_interval: 5s
#   static_configs:
#     - targets: ['localhost:9090']
```

---

## Service Monitor (CDRs)

![1762613686822](image/x/1762613686822.png)

![1762613701504](image/x/1762613701504.png)

> configure service monitors

![1762613874528](image/x/1762613874528.png)

```bash
# select release label
kubectl get prometheus.monitoring.coreos.com  -ojsonpath='{.items[0].spec.serviceMonitorSelector.matchLabels.release}'
```

![1762613949127](image/x/1762613949127.png)

```bash
kubectl apply -f service-monitor.yaml
```

---

## Adding Recording Rules

![1762614726591](image/x/1762614726591.png)

![1762614778594](image/x/1762614778594.png)

## Adding Alerts Rules

![1762614944695](image/x/1762614944695.png)

![1762614979368](image/x/1762614979368.png)

![1762615097695](image/x/1762615097695.png)

## Upgrade Helm Chart

![1762615144112](image/x/1762615144112.png)
