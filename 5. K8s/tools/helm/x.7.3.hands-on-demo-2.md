# **Simple, clean multi-environment setup** (dev / staging / prod)

## 📁 chart layout (one chart, 3 env files)

```ini
helm/
  myapp/
    Chart.yaml
    values.yaml            # shared defaults
    values-dev.yaml        # dev-only overrides
    values-staging.yaml    # staging-only overrides
    values-prod.yaml       # prod-only overrides
    templates/
      deployment.yaml
```

### values.yaml (shared defaults)

```yaml
replicaCount: 1
image:
  repository: CHANGEME_BY_PIPELINE # pipeline will set this
  tag: latest # pipeline will set this
resources: {}
```

### values-dev.yaml

```yaml
replicaCount: 1
ingress:
  enabled: true
  host: dev.myapp.example.com
```

### values-staging.yaml

```yaml
replicaCount: 2
ingress:
  enabled: true
  host: stg.myapp.example.com
```

### values-prod.yaml

```yaml
replicaCount: 3
ingress:
  enabled: true
  host: myapp.example.com
```

### deployment (uses repo+tag from pipeline)

```yaml
# helm/myapp/templates/deployment.yaml (snippet)
containers:
  - name: { { .Chart.Name } }
    image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
```

---

## 🐙 GitHub Actions (GHCR)

### 1. build & push (same as before — unchanged logic)

- produces tags: `:SHA`, `:branch`, `:latest (main)`

_(use your existing simple `build.yaml` from earlier)_

### 2. deploy per environment (choose env + tag)

`.github/workflows/deploy.yaml`

```yaml
name: Deploy to Kubernetes

on:
  workflow_dispatch:
    inputs:
      env:
        description: "Environment"
        required: true
        type: choice
        options: [dev, staging, prod]
      tag:
        description: "Image tag to deploy (e.g. main, 3a1c9f7, v1.2.0)"
        required: true

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: azure/setup-helm@v4
        with: { version: v3.15.1 }

      # (auth your kube context here)
      - name: Configure kubectl
        run: echo "kubectl context setup (e.g., az aks get-credentials ...)"

      - name: Set env vars
        id: env
        run: |
          case "${{ github.event.inputs.env }}" in
            dev)     echo "NS=dev" >> $GITHUB_OUTPUT;     echo "VALS=values-dev.yaml" >> $GITHUB_OUTPUT ;;
            staging) echo "NS=staging" >> $GITHUB_OUTPUT; echo "VALS=values-staging.yaml" >> $GITHUB_OUTPUT ;;
            prod)    echo "NS=prod" >> $GITHUB_OUTPUT;    echo "VALS=values-prod.yaml" >> $GITHUB_OUTPUT ;;
          esac

      - name: Helm upgrade --install (with env values)
        run: |
          IMAGE="ghcr.io/${{ github.repository_owner }}/myapp"
          TAG="${{ github.event.inputs.tag }}"
          CHART="./helm/myapp"
          NS="${{ steps.env.outputs.NS }}"
          VALS="${{ steps.env.outputs.VALS }}"

          helm upgrade --install myapp "$CHART" \
            --namespace "$NS" --create-namespace \
            -f "$CHART/$VALS" \
            --set image.repository="$IMAGE" \
            --set image.tag="$TAG" \
            --wait --atomic
```

**how to use:**

- run workflow → pick `env=staging`, `tag=main` (or a SHA like `3a1c9f7`)
- helm will load `values-staging.yaml` + set repo/tag
- result: **staging** gets exactly that image/tag

---

## 🟦 Azure DevOps (ACR)

### single pipeline, two stages (Build → Deploy) with env switch

`azure-pipelines.yaml`

```yaml
trigger:
  branches:
    include: ["*"]

variables:
  acrName: myacr
  imageName: myapp
  registry: $(acrName).azurecr.io
  chartPath: helm/myapp
  releaseName: myapp

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
                BRANCH=$(Build.SourceBranchName)
                docker build -t $IMAGE:$SHA -t $IMAGE:$BRANCH .
                docker push $IMAGE:$SHA
                docker push $IMAGE:$BRANCH
                if [ "$BRANCH" = "main" ]; then
                  docker tag $IMAGE:$SHA $IMAGE:latest
                  docker push $IMAGE:latest
                fi
          - bash: echo "##vso[task.setvariable variable=shortSha]$(Build.SourceVersion:0:7)"
            displayName: Save short SHA

  - stage: Deploy
    dependsOn: Build
    variables:
      # set at queue time: env = dev|staging|prod; tag = main|<sha>|vX.Y.Z
      env: dev
      tag: $(shortSha)
    jobs:
      - job: HelmDeploy
        pool: { vmImage: ubuntu-latest }
        steps:
          - checkout: self

          - task: AzureCLI@2
            inputs:
              azureSubscription: "MyAzureConnection"
              scriptType: bash
              scriptLocation: inlineScript
              inlineScript: |
                az aks get-credentials -g MyRG -n MyAKS --overwrite-existing

          - task: HelmInstaller@1

          - bash: |
              case "$(env)" in
                dev)     NS=dev;     VALS=values-dev.yaml;;
                staging) NS=staging; VALS=values-staging.yaml;;
                prod)    NS=prod;    VALS=values-prod.yaml;;
              esac

              IMAGE="$(registry)/$(imageName)"
              TAG="$(tag)"
              CHART="$(chartPath)"

              echo "Deploying ${IMAGE}:${TAG} to ${NS} with ${VALS}"
              helm upgrade --install "$(releaseName)" "$CHART" \
                --namespace "$NS" --create-namespace \
                -f "$CHART/$VALS" \
                --set image.repository="$IMAGE" \
                --set image.tag="$TAG" \
                --wait --atomic
            displayName: helm upgrade --install
```

**how to use:**

- queue the pipeline (or redeploy the `Deploy` stage) with:

  - `env=prod`
  - `tag=v1.2.0` (or `main` or a specific SHA)

- helm reads `values-prod.yaml` + repo/tag → deploys **prod** with that exact image

---

## 🧠 mental model (super simple)

- **Build** pushes images with multiple tags: `:SHA`, `:branch`, (`:latest` for main), maybe `:vX.Y.Z`.
- **Deploy** picks **one** tag + **one** env file:

  - `-f values-<env>.yaml`
  - `--set image.repository=... --set image.tag=<tag>`

That’s it. You can roll forward/back by redeploying a different **tag**, and keep each environment tuned with its own **values-\*.yaml**.
