# Install ArgoCD CLI  
## 1. Download the binary file
wget https://github.com/argoproj/argo-cd/releases/download/v3.1.9/argocd-linux-amd64

## 2. Move to /usr/local/bin
sudo mv ./argocd-linux-amd64 /usr/local/bin/argocd

## 3. Make it executable 
sudo chmod +x /usr/local/bin/argocd

## 4. login
argocd login argocd.local.com --insecure --username admin --password <YOUR_PASSWORD>
# or
argocd login argocd.local.com --insecure --sso-launch-browser 