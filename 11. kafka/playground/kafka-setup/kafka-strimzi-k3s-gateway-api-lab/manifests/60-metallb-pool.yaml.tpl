apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: kafka-gateway-pool
  namespace: metallb-system
spec:
  # A dedicated VIP keeps this lab deterministic and avoids consuming addresses
  # for unrelated LoadBalancer Services.
  addresses:
    - __LOAD_BALANCER_IP__-__LOAD_BALANCER_IP__
  autoAssign: false
---
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: kafka-gateway-l2
  namespace: metallb-system
spec:
  ipAddressPools:
    - kafka-gateway-pool
