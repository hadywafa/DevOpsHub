apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: kafka-lab
  labels:
    app.kubernetes.io/name: kafka-lab-ingress
    app.kubernetes.io/part-of: kafka-lab
spec:
  ingressClassName: traefik
  rules:
    - host: ui.__BASE_DOMAIN__
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: kafbat-ui
                port:
                  number: 8080
    - host: registry.__BASE_DOMAIN__
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: schema-registry
                port:
                  number: 8081
    - host: rest.__BASE_DOMAIN__
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: kafka-rest-proxy
                port:
                  number: 8082
