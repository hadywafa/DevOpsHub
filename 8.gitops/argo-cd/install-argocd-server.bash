# Install ArgoCD
##############################################################################################################
## 1. Add the Argo Helm repository
helm repo update
helm repo add argo https://argoproj.github.io/argo-helm

## 2. Install Argo CD using Helm
kubectl create namespace argocd
helm install argocd argo/argo-cd -n argocd

## 3. Access the Argo CD server UI

## Using Port Forwarding
### 3.1. Port-forward the Argo CD server service to localhost
kubectl port-forward svc/argocd-server -n argocd 8080:443

## Using Ingress Controller (Nginx controller)

### 3.1. upgrad argocd to use ingress
helm upgrade argocd \
--set config.params."server\.insecure"=true \
--set server.ingress.enabled=true \
--set server.ingress.ingressClassName="nginx" \
-n argocd argo/argo-cd

### 3.2. edit argocd ingress 
kubectl edit ingress argocd-server -n argocd

### 3.3. edit the hostname with your host, example -> argocd.local.com

### 3.4. add argocd.local.com as entry to your dns-server, example -> sudo vim /etc/hosts 

## 4. get password 
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo

## 5. Open your web browser and navigate to https://localhost:8080

## 6. Log in using the default admin credentials
###    - Username: admin
###    - Password: Retrieve the initial password with the following command:

##############################################################################################################
# Note: It is recommended to change the default password after the first login.
# Note: For production environments, consider setting up proper ingress and TLS for secure access.
##############################################################################################################

