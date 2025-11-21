# This Contain Real World Important Examples

## 1. Get all current installed helm charts in your cluster
```bash
helm list --all-namespaces --output json
```

## 2. Get Metadata for a specific chart in your cluster


```bash
helm get metadata <chart_name> --namespace <namespace>
```

## 3. Get Users Values for a specific chart

```bash
helm get values <chart_name> --namespace <namespace>

helm get values prometheus-community/kube-prometheus-stack --namespace monitoring
```

## 4. Show Default Values for a specific chart

```bash
helm show values <chart_name> --namespace <namespace>

helm show values prometheus-community/kube-prometheus-stack
```