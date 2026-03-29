# Notes

## Resources

1. https://registry.terraform.io/providers/hashicorp/aws/latest
2. https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest
3. https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest

## Testing Cluster using nginx app

### 1. _Connect with cluster with kubectl_

```bash
aws eks --region eu-north-1 update-kubeconfig --name hw-eks
```

- prerequisites

  - install kubectl
  - install azure-cli
  - install aws-authenticator

### 2. Create app.yaml file

```yaml
# deployment
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
        - name: nginx
          image: nginx:1.14.2
          ports:
            - containerPort: 80

---
# service
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
spec:
  selector:
    app: nginx
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
  type: LoadBalancer
```

```bash
# apply the deployment
kubectl apply -f setup/app.yaml
```
