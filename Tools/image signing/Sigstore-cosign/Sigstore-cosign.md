Yes, for your case:

```text
Cosign + Harbor/ACR + AKS + Kyverno
```

is the cleanest portable option.

Harbor supports Cosign signing since Harbor v2.5, and Kyverno can verify Cosign signatures stored in OCI registries. ([goharbor.io](https://goharbor.io/docs/main/working-with-projects/working-with-images/sign-images/?utm_source=chatgpt.com "Sign Artifacts with Cosign or Notation"))

---

# Recommended architecture

```text
ADO Pipeline
  build image
  push image to registry
  get digest
  sign digest with Cosign private key
  verify signature

Registry: ACR now / Harbor later
  stores image
  stores cosign signature

AKS
  Kyverno admission controller
  verifies image signature using cosign public key
  blocks unsigned images
```

---

# 1. Generate Cosign key pair

Do this once from secure machine:

```bash
cosign generate-key-pair
```

It creates:

```text
cosign.key   # private key - keep secret
cosign.pub   # public key - safe to share with cluster
```

Store:

```text
cosign.key → Azure DevOps Secure File / Key Vault / secret store
cosign.pub → Kubernetes Secret or ConfigMap for Kyverno
```

---

# 2. Build, push, sign, verify in ADO

```yaml
steps:
  - bash: |
      set -euo pipefail

      REGISTRY="myacr.azurecr.io"
      IMAGE_NAME="b2b-api"
      TAG="$(Build.BuildId)"

      IMAGE="$REGISTRY/$IMAGE_NAME:$TAG"

      echo "Building image: $IMAGE"
      docker build -t "$IMAGE" .

      echo "Pushing image..."
      docker push "$IMAGE"

      echo "Getting digest..."
      DIGEST=$(crane digest "$IMAGE")
      IMAGE_DIGEST="$REGISTRY/$IMAGE_NAME@$DIGEST"

      echo "Image digest: $IMAGE_DIGEST"

      echo "Signing image digest..."
      cosign sign --yes --key "$(COSIGN_KEY_PATH)" "$IMAGE_DIGEST"

      echo "Verifying signature..."
      cosign verify --key "$(COSIGN_PUBLIC_KEY_PATH)" "$IMAGE_DIGEST"

      echo "##vso[task.setvariable variable=SIGNED_IMAGE_DIGEST]$IMAGE_DIGEST"
    displayName: "Build, push, sign, verify image"
```

Important:

```text
Push first → get digest → sign digest
```

Cosign signs and publishes the signature to the OCI registry, and `cosign verify --key` verifies it later. ([Kyverno](https://main.kyverno.io/docs/policy-types/cluster-policy/verify-images/sigstore/?utm_source=chatgpt.com "Sigstore"))

---

# 3. Deploy using digest

Use this:

```yaml
image: myacr.azurecr.io/b2b-api@sha256:xxxx
```

Not this:

```yaml
image: myacr.azurecr.io/b2b-api:latest
```

A digest is the image fingerprint. Tag can move. Digest cannot.

---

# 4. Install Kyverno in AKS

Kyverno is easier than Gatekeeper/Ratify for Cosign.

```bash
helm repo add kyverno https://kyverno.github.io/kyverno/
helm repo update

helm install kyverno kyverno/kyverno \
  -n kyverno \
  --create-namespace
```

Check:

```bash
kubectl get pods -n kyverno
```

---

# 5. Create Kubernetes Secret with Cosign public key

```bash
kubectl create namespace image-policy

kubectl create secret generic cosign-public-key \
  -n image-policy \
  --from-file=cosign.pub=./cosign.pub
```

---

# 6. Create Kyverno policy to block unsigned images

Example for your registry/repo:

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: verify-signed-images
spec:
  validationFailureAction: Enforce
  background: false
  webhookConfiguration:
    failurePolicy: Fail
    timeoutSeconds: 30
  rules:
    - name: verify-cosign-signature
      match:
        any:
          - resources:
              kinds:
                - Pod
      verifyImages:
        - imageReferences:
            - "myacr.azurecr.io/b2b-api*"
          mutateDigest: true
          verifyDigest: true
          required: true
          attestors:
            - entries:
                - keys:
                    secret:
                      name: cosign-public-key
                      namespace: image-policy
```

Apply it:

```bash
kubectl apply -f verify-signed-images.yaml
```

Kyverno’s `verifyImages` rule supports Cosign public keys, certificates, and keyless attestors. ([Kyverno](https://kyverno.io/docs/policy-types/cluster-policy/verify-images/overview/?utm_source=chatgpt.com "Overview"))

---

# 7. Validate

## Signed image test

Deploy signed image:

```yaml
image: myacr.azurecr.io/b2b-api@sha256:<signed-digest>
```

Expected:

```text
Pod allowed
```

Check:

```bash
kubectl get pods
kubectl describe pod <pod-name>
```

---

## Unsigned image test

Build/push another image but do not sign it:

```bash
docker build -t myacr.azurecr.io/b2b-api:unsigned .
docker push myacr.azurecr.io/b2b-api:unsigned
```

Try to deploy:

```yaml
image: myacr.azurecr.io/b2b-api:unsigned
```

Expected:

```text
Pod rejected
```

Check events:

```bash
kubectl get events -A | grep -i "verify\|signature\|denied\|kyverno"
```

Also check Kyverno reports:

```bash
kubectl get policyreport -A
kubectl describe clusterpolicy verify-signed-images
```

---

# 8. If you move from ACR to Harbor

Only change this:

```bash
REGISTRY="harbor.company.local/project"
```

Example:

```bash
IMAGE="harbor.company.local/b2b/b2b-api:$(Build.BuildId)"
```

Kyverno policy becomes:

```yaml
imageReferences:
  - "harbor.company.local/b2b/b2b-api*"
```

No major redesign.

---

# 9. Gatekeeper option

Gatekeeper alone does not verify Cosign signatures directly. Usually you need:

```text
Gatekeeper + Ratify
```

Ratify can verify Cosign signatures, and Gatekeeper handles the admission policy. ([ratify.dev](https://ratify.dev/docs/plugins/verifier/cosign/?utm_source=chatgpt.com "Cosign | A cloud-native verification engine - Ratify"))

Use Gatekeeper/Ratify only if your company already uses OPA Gatekeeper.

For your case, I recommend:

```text
Kyverno first
Gatekeeper + Ratify only if required by security team
```

---

# Final choice

Use this implementation:

```text
Cosign key pair
ADO Secure File for cosign.key
Registry: ACR now, Harbor later
Kyverno verifyImages in AKS
Deploy by digest
Block unsigned images with Enforce mode
```

This is portable, simple, and not tied to Azure.