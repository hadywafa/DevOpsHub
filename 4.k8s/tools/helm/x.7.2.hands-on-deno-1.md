# 🚀 **Helm CI/CD Integration & GitOps Patterns**

Here’s a **simpler version** of how Helm CI/CD works with **image tagging** for both GitHub Actions (GHCR) and Azure DevOps (ACR).

---

## 🧭 Tagging Logic (Same for Both)

Each image gets multiple tags:

| Tag Type    | Example       | When                        |
| ----------- | ------------- | --------------------------- |
| Commit SHA  | `3a1c9f7`     | Every build                 |
| Branch Name | `main`, `dev` | Every branch                |
| Version Tag | `v1.2.0`      | When you push a version tag |
| Latest      | `latest`      | For main branch             |

👉 You can deploy any of these tags later via Helm.

---

## 🐙 GitHub Actions + GHCR

### 🔹 build.yaml

Build and push Docker image to GHCR:

```yaml
name: Build and Push Image
on:
  push:
    branches: ["**"]
    tags: ["v*.*.*"]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: docker/login-action@v3
        with:
          registry: ghcr.io
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}

      - name: Build & Push
        run: |
          IMAGE=ghcr.io/${{ github.repository_owner }}/myapp
          SHA=${GITHUB_SHA::7}
          BRANCH=${GITHUB_REF_NAME}

          docker build -t $IMAGE:$SHA -t $IMAGE:$BRANCH .
          docker push $IMAGE:$SHA
          docker push $IMAGE:$BRANCH
          if [ "$BRANCH" = "main" ]; then
            docker tag $IMAGE:$SHA $IMAGE:latest
            docker push $IMAGE:latest
          fi
```

✅ Output example in GHCR:

```
ghcr.io/user/myapp:3a1c9f7
ghcr.io/user/myapp:main
ghcr.io/user/myapp:latest
```

---

### 🔹 deploy.yaml

Deploy using Helm:

```yaml
name: Deploy to Kubernetes
on:
  workflow_dispatch:
    inputs:
      tag:
        description: "Image tag (e.g. main, 3a1c9f7)"
        required: true

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: azure/setup-helm@v4
      - run: |
          IMAGE=ghcr.io/${{ github.repository_owner }}/myapp
          TAG=${{ github.event.inputs.tag }}
          helm upgrade --install myapp ./helm/myapp \
            --set image.repository=$IMAGE \
            --set image.tag=$TAG
```

✅ Example:

```bash
helm upgrade --install myapp ./helm/myapp \
  --set image.repository=ghcr.io/user/myapp \
  --set image.tag=3a1c9f7
```

---

## 🟦 Azure DevOps + ACR

### 🔹 azure-pipelines.yaml

Simple 2-stage pipeline.

```yaml
trigger:
  branches:
    include: ["*"]

variables:
  acrName: myacr
  imageName: myapp
  registry: $(acrName).azurecr.io

stages:
  - stage: Build
    jobs:
      - job: BuildAndPush
        pool: { vmImage: ubuntu-latest }
        steps:
          - checkout: self
          - task: AzureCLI@2
            inputs:
              azureSubscription: "MyAzureConnection"
              scriptType: bash
              scriptLocation: inlineScript
              inlineScript: |
                az acr login -n $(acrName)
                IMAGE=$(registry)/$(imageName)
                SHA=$(Build.SourceVersion:0:7)
                docker build -t $IMAGE:$SHA -t $IMAGE:$(Build.SourceBranchName) .
                docker push $IMAGE:$SHA
                docker push $IMAGE:$(Build.SourceBranchName)
                if [ "$(Build.SourceBranchName)" = "main" ]; then
                  docker tag $IMAGE:$SHA $IMAGE:latest
                  docker push $IMAGE:latest
                fi

  - stage: Deploy
    dependsOn: Build
    jobs:
      - job: Deploy
        pool: { vmImage: ubuntu-latest }
        steps:
          - task: AzureCLI@2
            inputs:
              azureSubscription: "MyAzureConnection"
              scriptType: bash
              scriptLocation: inlineScript
              inlineScript: |
                az aks get-credentials -g MyRG -n MyAKS --overwrite-existing
                IMAGE=$(registry)/$(imageName)
                TAG=$(Build.SourceBranchName)
                helm upgrade --install myapp helm/myapp \
                  --set image.repository=$IMAGE \
                  --set image.tag=$TAG
```

✅ Output example in ACR:

```
myacr.azurecr.io/myapp:3a1c9f7
myacr.azurecr.io/myapp:dev
myacr.azurecr.io/myapp:latest
```

---

## ⚙️ Helm Chart (Deployment Snippet)

```yaml
containers:
  - name: { { .Chart.Name } }
    image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
```

---

## 🧩 Summary

| Step     | GitHub Actions       | Azure DevOps        |
| -------- | -------------------- | ------------------- |
| Build    | Build & push to GHCR | Build & push to ACR |
| Tag      | SHA, branch, latest  | SHA, branch, latest |
| Deploy   | Manual (choose tag)  | Auto (branch tag)   |
| Registry | ghcr.io              | myacr.azurecr.io    |
