# Install Kustomize
curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh" | bash
# check the version
kustomize version --short

## Kustomize Usage
# 1. Make kubectl apply -f . easy