# ⁉️ EX 4

<div align="center" style="background-color:#141414; border-radius: 10px; border: 2px solid; width: 100%">
<img src="image/ex4.png" alt="istio installation" style="width: 70%">
</div>

---

```yaml
apiVersion: cilium.io/v2
kind: CiliumClusterwideNetworkPolicy
metadata:
  name: allow-dns-clusterwide
spec:
  endpointSelector: {}
  egress:
    - toEndpoints:
        - matchLabels:
            k8s:io.kubernetes.pod.namespace: kube-system
            k8s:k8s-app: kube-dns
      toPorts:
        - ports:
            - port: "53"
              protocol: ANY
          rules:
            dns:
              - matchPattern: "*"
```
