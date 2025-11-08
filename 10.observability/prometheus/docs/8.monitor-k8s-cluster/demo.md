# Demo

## Deploy Prometheus in K8s

```bash
# add helm repo for prometheus community
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
# update helm repo for prometheus community
helm repo update
# install prometheus
helm install prometheus prometheus-community/kube-prometheus-stack --version 45.7.1 --namespace monitoring --create-namespace
```

```bash
# to search all helm chart available for prometheus-community:
helm search repo prometheus-community
# to search specific chart version:
helm search repo prometheus-community/kube-prometheus-stack --versions
# to install specific version:
helm install prometheus prometheus-community/kube-prometheus-stack --version 14.0.1
# to upgrade:
helm upgrade --install prometheus prometheus-community/kube-prometheus-stack
# to uninstall:
helm uninstall prometheus
```
