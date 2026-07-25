Yes, it works like that **only if the agent is already authenticated to ACR**.

`cosign sign` does **not** choose/authenticate to ACR by itself. It reads the registry from the image name:

```bash
IMAGE_DIGEST="myacr.azurecr.io/b2b-api@sha256:xxxx"
```

So Cosign knows:

```text
Registry = myacr.azurecr.io
Repo     = b2b-api
Digest   = sha256:xxxx
```

Then it pushes the signature to the same registry/repo. Your docs also show that `cosign verify --key` verifies the image against the given key and image URI, and that Cosign validates the image digest claim by default.

---

## 1. ACR authentication before Cosign

In ADO, do one of these before `cosign sign`.

### Option A: Azure CLI login

```bash
az acr login --name myacr
```

Then:

```bash
cosign sign --yes --key "$COSIGN_KEY" "$IMAGE_DIGEST"
```

### Option B: Docker login

```bash
echo "$ACR_PASSWORD" | docker login myacr.azurecr.io \
  -u "$ACR_USERNAME" \
  --password-stdin
```

Then Cosign can reuse the Docker registry credentials.

### Required permission

The identity must have permission to push to ACR:

```text
AcrPush
```

Because Cosign is not pushing the image, but it **is pushing the signature artifact**.

---

## 2. Best way: generate key directly inside Azure Key Vault

Do **not** generate local `cosign.key` then upload it if you can avoid it.

Use KMS mode:

```bash
cosign generate-key-pair \
  --kms azurekms://my-keyvault-name.vault.azure.net/cosign-signing-key
```

Then export public key:

```bash
cosign public-key \
  --key azurekms://my-keyvault-name.vault.azure.net/cosign-signing-key \
  > cosign.pub
```

Your pasted reference confirms Cosign supports `generate-key-pair --kms`, exporting the public key using `cosign public-key --key <provider>://<key>`, and Azure Key Vault through `azurekms://...`.

---

## 3. Azure auth for Key Vault signing

Cosign needs these env vars to access Azure Key Vault:

```bash
export AZURE_TENANT_ID="xxxxx"
export AZURE_CLIENT_ID="xxxxx"
export AZURE_CLIENT_SECRET="xxxxx"
```

The service principal needs Key Vault permission:

```text
Key Vault Crypto User
```

For creating the key, it needs higher permission:

```text
Key Vault Crypto Officer
```

Your reference says Azure Key Vault signing uses `AZURE_TENANT_ID`, `AZURE_CLIENT_ID`, `AZURE_CLIENT_SECRET`, and signing needs permissions like **Key Vault Crypto User**.

---

## 4. Sign image using Azure Key Vault key

```bash
cosign sign --yes \
  --key azurekms://my-keyvault-name.vault.azure.net/cosign-signing-key \
  "$IMAGE_DIGEST"
```

This will:

```text
1. Use Key Vault key to sign
2. Push signature to ACR/Harbor beside the image
```

But again, registry auth must already exist.

---

## 5. Verify image

Using Key Vault key:

```bash
cosign verify \
  --key azurekms://my-keyvault-name.vault.azure.net/cosign-signing-key \
  "$IMAGE_DIGEST"
```

Or better for AKS/Kyverno:

```bash
cosign verify \
  --key cosign.pub \
  "$IMAGE_DIGEST"
```

Cosign can export the public key from KMS and verify using that public key file.

---

## 6. Full ADO pipeline shape

```yaml
steps:
  - bash: |
      set -euo pipefail

      az acr login --name myacr

      IMAGE="myacr.azurecr.io/b2b-api:$(Build.BuildId)"

      docker build -t "$IMAGE" .
      docker push "$IMAGE"

      DIGEST=$(crane digest "$IMAGE")
      IMAGE_DIGEST="myacr.azurecr.io/b2b-api@$DIGEST"

      export AZURE_TENANT_ID="$(AZURE_TENANT_ID)"
      export AZURE_CLIENT_ID="$(AZURE_CLIENT_ID)"
      export AZURE_CLIENT_SECRET="$(AZURE_CLIENT_SECRET)"

      COSIGN_KMS_KEY="azurekms://my-keyvault-name.vault.azure.net/cosign-signing-key"

      cosign sign --yes --key "$COSIGN_KMS_KEY" "$IMAGE_DIGEST"

      cosign verify --key "$COSIGN_KMS_KEY" "$IMAGE_DIGEST"

      echo "##vso[task.setvariable variable=SIGNED_IMAGE_DIGEST]$IMAGE_DIGEST"
    displayName: "Build, push, sign image with Cosign Key Vault"
```

---

## 7. For Harbor later

Only auth and registry name change.

```bash
docker login harbor.company.local
```

Image:

```bash
IMAGE="harbor.company.local/b2b/b2b-api:$(Build.BuildId)"
```

Cosign command stays same:

```bash
cosign sign --yes --key "$COSIGN_KMS_KEY" "$IMAGE_DIGEST"
```

Because Cosign reads the registry from:

```text
harbor.company.local/b2b/b2b-api@sha256:xxxx
```

---

## Final answer

`cosign sign` authenticates to **two places**:

```text
1. Registry auth
   Needed to push the signature to ACR/Harbor.
   Usually from docker login or az acr login.

2. Key Vault auth
   Needed to use the private signing key.
   From AZURE_TENANT_ID / AZURE_CLIENT_ID / AZURE_CLIENT_SECRET.
```

So yes, it works — but only after both authentications are configured.