# This Contain Real World Important Examples

# 0.add helm repo
helm repo list
helm search prometheus
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm install prometheus-community/kube-prometheus-stack \
    --generate-name \
    --namespace monitoring \
    --create-namespace \
    --version 45.7.1 \
    --values values.yaml
## 1. Get all current installed helm charts in your cluster
helm list --all-namespaces --output json

## 2. Get Metadata for a specific chart in your cluster
helm get metadata <chart_name> --namespace <namespace>

## 3. Get Users Values for a specific chart
helm get values <chart_name> --namespace <namespace>
helm get values prometheus-community/kube-prometheus-stack --namespace monitoring

## 4. Show Default Values for a specific chart
helm show values <chart_name> --namespace <namespace>
helm show values prometheus-community/kube-prometheus-stack --namespace monitoring