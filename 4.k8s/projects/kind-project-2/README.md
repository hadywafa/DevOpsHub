# Tiny prereqs (one-time)

**Add local hostnames:**

- **Ubuntu**

```bash
echo '127.0.0.1 local.test' | sudo tee -a /etc/hosts
```

- **Windows (PowerShell as Admin)**

```powershell
Add-Content -Path "C:\Windows\System32\drivers\etc\hosts" -Value "`n127.0.0.1 local.test"
```

You need Docker running, plus `kubectl` and `kind` installed.

---

## 1. Create a small multi-node Kind cluster (with Ingress ports)

Create `kind.yaml`:

```yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
name: project2
nodes:
  - role: control-plane
  - role: worker
  - role: worker
    # Add the ingress-ready label (later used to make sure ingress controller pod run on that node)

    kubeadmConfigPatches:
      - |
        kind: InitConfiguration
        nodeRegistration:
          kubeletExtraArgs:
            node-labels: "ingress-ready=true"

    extraPortMappings:
      - containerPort: 80 # expose ingress 80 -> localhost:80
        hostPort: 80
        protocol: TCP
      - containerPort: 443 # (optional) expose 443
        hostPort: 443
        protocol: TCP
# if label not added, please use this command
# kubectl label node project2-worker2 ingress-ready=true
```

---

Create it:

```bash
kind create cluster --config kind.yaml
kubectl get nodes
```

---

## 2. Install the Ingress controller (nginx)

```bash
# install the ingress (nginx) controller in the kind cluster
# kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

kubectl apply -f ./2.ingress-nginx.yaml
# make sure you have
# ingress-ready: "true"
# under deployment.spec.template.spec.nodeSelector
#####
# “Wait up to 3 minutes for all NGINX Ingress Controller pods in the ingress-nginx namespace to become Ready
# It’s a way to pause scripts or automation (like CI/CD or Helm installs) until the Ingress Controller is actually running and healthy.
kubectl -n ingress-nginx wait --for=condition=ready pod -l app.kubernetes.io/component=controller --timeout=180s
```

---

## 3. Minimal app + ingress (frontend + api)

Create `stack.yaml`:

```yaml
---
apiVersion: v1
kind: Namespace
metadata:
  name: project2

# ===== API (echo) =====
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api
  namespace: project2
spec:
  replicas: 1
  selector: { matchLabels: { app: api } }
  template:
    metadata: { labels: { app: api } }
    spec:
      containers:
        - name: http-echo
          image: hashicorp/http-echo
          args: ["-text=hello-from-api", "-listen=:5678"]
          ports: [{ containerPort: 5678 }]
---
apiVersion: v1
kind: Service
metadata:
  name: api
  namespace: project2
spec:
  selector: { app: api }
  ports:
    - port: 80
      targetPort: 5678

# ===== Frontend (static html) =====
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: frontend-html
  namespace: project2
data:
  index.html: |
    <html>
      <body style="font-family:sans-serif">
        <h1>Hello from Frontend (Kind)</h1>
        <p>Try the API at <code>/api/</code></p>
      </body>
    </html>
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend
  namespace: project2
spec:
  replicas: 1
  selector: { matchLabels: { app: frontend } }
  template:
    metadata: { labels: { app: frontend } }
    spec:
      containers:
        - name: nginx
          image: nginx:alpine
          ports: [{ containerPort: 80 }]
          volumeMounts:
            - name: web
              mountPath: /usr/share/nginx/html
      volumes:
        - name: web
          configMap: { name: frontend-html }
---
apiVersion: v1
kind: Service
metadata:
  name: frontend
  namespace: project2
spec:
  selector: { app: frontend }
  ports:
    - port: 80
      targetPort: 80

# ===== Ingress (paths) =====
# host: local.test
#   /api/ -> api
#   /     -> frontend
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: web
  namespace: project2
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  ingressClassName: nginx
  rules:
    - host: local.com
      http:
        paths:
          - path: /api
            pathType: Prefix
            backend:
              service:
                name: api
                port:
                  number: 80
          - path: /
            pathType: Prefix
            backend:
              service:
                name: frontend
                port:
                  number: 80
```

Apply:

```bash
kubectl apply -f stack.yaml
kubectl -n project2 rollout status deploy/frontend
kubectl -n project2 rollout status deploy/api
```

---

## 4. Quick test

```bash
# Frontend home:
curl -s http://local.com/ | sed -n '1,3p'

# API at /api/:
curl -s http://local.com/api/
# expect: hello-from-api
```

Open a browser to `http://local.com/`.

---

## 5. Clean up

```bash
kind delete cluster --name project2
```

---

## That’s it

You now have the **simplest possible** local setup that still looks like real life:

- multi-node Kind
- nginx Ingress
- path-based routing (`/` → frontend, `/api/` → API)

When you’re ready, we can plug in Redis/RabbitMQ or switch to a real `LoadBalancer` emulator — but this is the cleanest starting point.

- <https://kind.sigs.k8s.io/docs/user/quick-start/#kind-with-nginx-ingress>
- <https://kind.sigs.k8s.io/docs/user/quick-start/#kind-with-nginx-ingress>
- <https://kind.sigs.k8s.io/docs/user/quick-start/#kind-with-nginx-ingress>
