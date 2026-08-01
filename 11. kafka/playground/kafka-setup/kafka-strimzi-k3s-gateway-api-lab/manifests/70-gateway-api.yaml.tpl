apiVersion: gateway.networking.k8s.io/v1
kind: GatewayClass
metadata:
  name: envoy
spec:
  controllerName: gateway.envoyproxy.io/gatewayclass-controller
---
apiVersion: gateway.envoyproxy.io/v1alpha1
kind: EnvoyProxy
metadata:
  name: kafka-gateway-proxy
  namespace: __NAMESPACE__
spec:
  provider:
    type: Kubernetes
    kubernetes:
      envoyDeployment:
        replicas: 1
        container:
          resources:
            requests:
              cpu: 50m
              memory: 128Mi
            limits:
              cpu: 500m
              memory: 256Mi
      envoyService:
        type: LoadBalancer
        allocateLoadBalancerNodePorts: false
        externalTrafficPolicy: Cluster
        annotations:
          metallb.io/address-pool: kafka-gateway-pool
---
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: kafka-gateway
  namespace: __NAMESPACE__
spec:
  gatewayClassName: envoy
  addresses:
    - type: IPAddress
      value: __LOAD_BALANCER_IP__
  infrastructure:
    parametersRef:
      group: gateway.envoyproxy.io
      kind: EnvoyProxy
      name: kafka-gateway-proxy
  listeners:
    - name: http
      protocol: HTTP
      port: 80
      allowedRoutes:
        namespaces:
          from: Same
---
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: kafbat-ui
  namespace: __NAMESPACE__
spec:
  parentRefs:
    - name: kafka-gateway
      sectionName: http
  hostnames:
    - ui.__BASE_DOMAIN__
  rules:
    - backendRefs:
        - name: kafbat-ui
          port: 8080
---
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: schema-registry
  namespace: __NAMESPACE__
spec:
  parentRefs:
    - name: kafka-gateway
      sectionName: http
  hostnames:
    - registry.__BASE_DOMAIN__
  rules:
    - backendRefs:
        - name: schema-registry
          port: 8081
---
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: kafka-rest-proxy
  namespace: __NAMESPACE__
spec:
  parentRefs:
    - name: kafka-gateway
      sectionName: http
  hostnames:
    - rest.__BASE_DOMAIN__
  rules:
    - backendRefs:
        - name: kafka-rest-proxy
          port: 8082
