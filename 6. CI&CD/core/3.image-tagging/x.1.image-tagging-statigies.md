# 🧭 Scenario setup (fixed numbers so nothing’s vague)

- **App/Repo:** `ordersvc`
- **Registry:** `contoso.azurecr.io/ordersvc` (ACR or any OCI registry)
- **Branches:** `feature/*` → `dev` → PR to `main`
- **Version planned for release:** `1.4.0`
- **Environments:** `dev` → `staging` → `prod`
- **We deploy by:** **digest** (immutable), not by tag
- **Primary immutable tag:** `git-<shortsha>`
- **RC/Release tags:** `1.4.0-rc.N` on staging; `1.4.0`, `1.4`, `1`, `stable` on prod

> I’ll simulate two features and one release:
>
> - Feature A: PR **#101**, commit **`a1b2c3d4`**
> - Feature B: PR **#102**, commit **`b2c3d4e5`**
> - Dev build numbers: **#233**, **#234**
> - Image digests (fake but realistic):
>
>   - From Feature A (PR build): `sha256:aaa111...`
>   - Dev build #233: `sha256:111aaa...`
>   - Dev build #234: `sha256:222bbb...` ← becomes our RC & release
>
> - RC tag we’ll create: **`1.4.0-rc.1`**
> - Final release tags: **`1.4.0`**, `1.4`, `1`, `stable`

---

## 🧪 Stage 1 — PR #101 from `feature/A` → `dev` (validation build)

**What we build:** the **PR merge ref** (the would-be merge result into `dev`), not only the head.
**We may push temporary tags** for preview envs, but this is _not_ the promotable artifact.

**Computed values (example):**

- PR ID: `101`
- Merge ref short SHA (build source): `a1b2c3d4`
- Temp image tags pushed:

  - `contoso.azurecr.io/ordersvc:git-a1b2c3d4`
  - `contoso.azurecr.io/ordersvc:pr-101`

- Resulting **digest:** `sha256:aaa111deadbeef...` (immutable)

**Expected console output (key lines):**

```ini
docker build -t contoso.azurecr.io/ordersvc:git-a1b2c3d4 .
docker tag contoso.azurecr.io/ordersvc:git-a1b2c3d4 contoso.azurecr.io/ordersvc:pr-101
docker push contoso.azurecr.io/ordersvc:git-a1b2c3d4
docker push contoso.azurecr.io/ordersvc:pr-101
DIGEST=contoso.azurecr.io/ordersvc@sha256:aaa111deadbeef...
echo $DIGEST > image_digest.txt   # used for preview deploy by digest
```

**Preview deploy to ephemeral env (optional):**

```yaml
image:
  repository: contoso.azurecr.io/ordersvc
  digest: sha256:aaa111deadbeef... # from image_digest.txt
```

> ✅ Goal here: fast feedback. This image is _not_ used later for release.

---

## ✅ Stage 2 — Merge PR #101 into `dev` ⇒ **Dev build #233** (canonical dev artifact at this point)

**New dev commit short SHA:** `7e4f9a1c` (merge/squash commit)
**We build once and push tags:**

- `contoso.azurecr.io/ordersvc:git-7e4f9a1c` (primary immutable)
- (optional pointer) `contoso.azurecr.io/ordersvc:dev`

**Resulting digest:** `sha256:111aaabbbccc...`

**Expected console output:**

```ini
docker build -t contoso.azurecr.io/ordersvc:git-7e4f9a1c .
docker push contoso.azurecr.io/ordersvc:git-7e4f9a1c
DIGEST=contoso.azurecr.io/ordersvc@sha256:111aaabbbccc...
docker tag contoso.azurecr.io/ordersvc:git-7e4f9a1c contoso.azurecr.io/ordersvc:dev
docker push contoso.azurecr.io/ordersvc:dev
```

**Dev deploy by digest:**

```yaml
image:
  repository: contoso.azurecr.io/ordersvc
  digest: sha256:111aaabbbccc... # EXACT artifact we built on dev
```

---

## 🧪 Stage 3 — PR #102 from `feature/B` → `dev` (validation build)

**PR ID:** `102`
**PR merge ref short SHA:** `b2c3d4e5`
**Temp tags:** `git-b2c3d4e5`, `pr-102`
**Digest (PR build):** `sha256:bbb222cafebabe...`

(Preview as before if needed)

---

## ✅ Stage 4 — Merge PR #102 into `dev` ⇒ **Dev build #234** (this _will_ be our release candidate)

**Dev commit short SHA:** `9a8b7c6d`
**We build and push:**

- `contoso.azurecr.io/ordersvc:git-9a8b7c6d`
- (optional) `contoso.azurecr.io/ordersvc:dev`

**Digest:** `sha256:222bbbcccdde...` ← **THIS** is our RC/release image

**Expected output:**

```ini
docker build -t contoso.azurecr.io/ordersvc:git-9a8b7c6d .
docker push contoso.azurecr.io/ordersvc:git-9a8b7c6d
DIGEST=contoso.azurecr.io/ordersvc@sha256:222bbbcccdde...
docker tag contoso.azurecr.io/ordersvc:git-9a8b7c6d contoso.azurecr.io/ordersvc:dev
docker push contoso.azurecr.io/ordersvc:dev
```

**Dev deploy by digest:**

```yaml
image:
  repository: contoso.azurecr.io/ordersvc
  digest: sha256:222bbbcccdde...
```

---

## 🚦 Stage 5 — PR `dev` → `main` (Release Candidate creation) — **no rebuild**

We freeze the candidate by **tagging the exact digest** from Dev build #234.

**We add RC tag:** `contoso.azurecr.io/ordersvc:1.4.0-rc.1` → points to **`sha256:222bbbcccdde...`**

**Expected output:**

```ini
docker pull contoso.azurecr.io/ordersvc:git-9a8b7c6d
docker tag  contoso.azurecr.io/ordersvc:git-9a8b7c6d contoso.azurecr.io/ordersvc:1.4.0-rc.1
docker push contoso.azurecr.io/ordersvc:1.4.0-rc.1
```

**Staging deploy by digest:**

```yaml
image:
  repository: contoso.azurecr.io/ordersvc
  digest: sha256:222bbbcccdde...
```

**Run release validations on staging** (e2e, perf, DAST, vuln gate, etc.).
If anything fails, fix on `dev`, repeat Dev build (#235), and mint `1.4.0-rc.2` from the _new_ digest.

---

## 🚀 Stage 6 — Merge PR to `main` (Release) — **no rebuild; promote the same digest**

The PR is approved; we merge to `main`. We **promote** the same digest used in staging (`sha256:222bbbcccdde...`) to release tags:

**Add tags to that same digest:**

- `1.4.0` (immutable release)
- `1.4` (floating minor)
- `1` (floating major)
- `stable` and/or `prod` (org preference)

**Expected output:**

```ini
docker pull contoso.azurecr.io/ordersvc:git-9a8b7c6d
for T in 1.4.0 1.4 1 stable; do
  docker tag  contoso.azurecr.io/ordersvc:git-9a8b7c6d contoso.azurecr.io/ordersvc:$T
  docker push contoso.azurecr.io/ordersvc:$T
done
```

**Prod deploy by digest (same as staging):**

```yaml
image:
  repository: contoso.azurecr.io/ordersvc
  digest: sha256:222bbbcccdde...
```

---

## 📦 Registry state snapshots (what you’ll see)

### After Stage 2 (Dev build #233 done)

| Tag                       | Points to digest           | Notes                  |
| ------------------------- | -------------------------- | ---------------------- |
| `git-7e4f9a1c`            | `sha256:111aaabbbccc...`   | immutable dev artifact |
| `dev`                     | `sha256:111aaabbbccc...`   | moving pointer         |
| `git-a1b2c3d4` (PR build) | `sha256:aaa111deadbeef...` | from PR #101           |
| `pr-101`                  | `sha256:aaa111deadbeef...` | preview only           |

### After Stage 4 (Dev build #234 done)

| Tag                       | Points to digest           | Notes                     |
| ------------------------- | -------------------------- | ------------------------- |
| `git-9a8b7c6d`            | `sha256:222bbbcccdde...`   | **candidate for release** |
| `dev`                     | `sha256:222bbbcccdde...`   | moved to latest dev       |
| `git-7e4f9a1c`            | `sha256:111aaabbbccc...`   | previous dev              |
| `git-b2c3d4e5` (PR build) | `sha256:bbb222cafebabe...` | from PR #102              |
| `pr-102`                  | `sha256:bbb222cafebabe...` | preview only              |

### After Stage 5 (RC created)

| Tag          | Points to digest         |
| ------------ | ------------------------ |
| `1.4.0-rc.1` | `sha256:222bbbcccdde...` |

### After Stage 6 (Release promoted)

| Tag      | Points to digest         |
| -------- | ------------------------ |
| `1.4.0`  | `sha256:222bbbcccdde...` |
| `1.4`    | `sha256:222bbbcccdde...` |
| `1`      | `sha256:222bbbcccdde...` |
| `stable` | `sha256:222bbbcccdde...` |

> 🔁 Rollback later? Just redeploy the previous prod digest (e.g., `sha256:111aaabbbccc...`)—no rebuild needed.

---

## 🔧 Minimal Azure DevOps YAML (drop-in)

### PR pipeline (validation; optional push)

```yaml
# .azure-pipelines/pr.yml
trigger: none
pr:
  branches:
    include: [dev]
jobs:
  - job: pr_validation
    steps:
      - bash: |
          set -e
          IMG="contoso.azurecr.io/ordersvc"
          SHORT_SHA=$(echo $(Build.SourceVersion) | cut -c1-8)
          PR_ID=$(System.PullRequest.PullRequestId)
          docker build -t $IMG:git-$SHORT_SHA .
          # Optional preview tags:
          docker tag  $IMG:git-$SHORT_SHA $IMG:pr-$PR_ID
          az acr login -n contoso
          docker push $IMG:git-$SHORT_SHA
          docker push $IMG:pr-$PR_ID
          DIGEST=$(docker inspect --format='{{index .RepoDigests 0}}' $IMG:git-$SHORT_SHA)
          echo $DIGEST > image_digest.txt
        displayName: Build & (optionally) Push PR
      - publish: image_digest.txt
        artifact: pr_image
```

### Dev pipeline (canonical artifact)

```yaml
# .azure-pipelines/dev.yml
trigger:
  branches:
    include: [dev]
jobs:
  - job: build_push_dev
    steps:
      - bash: |
          set -e
          IMG="contoso.azurecr.io/ordersvc"
          SHORT_SHA=$(echo $(Build.SourceVersion) | cut -c1-8)
          docker build -t $IMG:git-$SHORT_SHA .
          az acr login -n contoso
          docker push $IMG:git-$SHORT_SHA
          DIGEST=$(docker inspect --format='{{index .RepoDigests 0}}' $IMG:git-$SHORT_SHA)
          echo $DIGEST > image_digest.txt
          docker tag  $IMG:git-$SHORT_SHA $IMG:dev
          docker push $IMG:dev
        displayName: Build & Push Dev
      - publish: image_digest.txt
        artifact: image

  - job: deploy_dev
    dependsOn: build_push_dev
    steps:
      - download: current
        artifact: image
      - bash: |
          set -e
          DIGEST=$(cat $(Pipeline.Workspace)/image/image_digest.txt)
          # DIGEST like: contoso.azurecr.io/ordersvc@sha256:222bbbcccdde...
          # strip before @ if Helm chart expects plain digest
          HELM_DIGEST=${DIGEST#*@}
          helm upgrade --install ordersvc charts/ordersvc --set image.repository="contoso.azurecr.io/ordersvc" --set image.digest="$HELM_DIGEST"
        displayName: Deploy to Dev by Digest
```

### RC pipeline (PR `dev`→`main`, promote-only)

```yaml
# .azure-pipelines/rc.yml
trigger: none
pr:
  branches:
    include: [main]
jobs:
  - job: tag_rc
    steps:
      - bash: |
          set -e
          IMG="contoso.azurecr.io/ordersvc"
          SHORT_SHA=$(echo $(Build.SourceVersion) | cut -c1-8)  # commit already built on dev
          RC="1.4.0-rc.1"
          az acr login -n contoso
          docker pull $IMG:git-$SHORT_SHA
          docker tag  $IMG:git-$SHORT_SHA $IMG:$RC
          docker push $IMG:$RC
          DIGEST=$(docker inspect --format='{{index .RepoDigests 0}}' $IMG:git-$SHORT_SHA)
          echo $DIGEST > image_digest.txt
        displayName: Create RC tag on existing digest
      - publish: image_digest.txt
        artifact: rc_image

  - job: deploy_staging
    dependsOn: tag_rc
    steps:
      - download: current
        artifact: rc_image
      - bash: |
          set -e
          DIGEST=$(cat $(Pipeline.Workspace)/rc_image/image_digest.txt)
          helm upgrade --install ordersvc-staging charts/ordersvc --set image.repository="contoso.azurecr.io/ordersvc" --set image.digest="${DIGEST#*@}"
        displayName: Deploy RC to Staging by Digest
```

### Release pipeline (merge to `main`, promote-only)

```yaml
# .azure-pipelines/release.yml
trigger:
  branches:
    include: [main]
jobs:
  - job: promote_release
    steps:
      - bash: |
          set -e
          IMG="contoso.azurecr.io/ordersvc"
          SHORT_SHA=$(echo $(Build.SourceVersion) | cut -c1-8)
          VER="1.4.0"
          az acr login -n contoso
          docker pull $IMG:git-$SHORT_SHA
          for T in $VER ${VER%.*} ${VER%%.*} stable; do
            docker tag  $IMG:git-$SHORT_SHA $IMG:$T
            docker push $IMG:$T
          done
          DIGEST=$(docker inspect --format='{{index .RepoDigests 0}}' $IMG:git-$SHORT_SHA)
          echo $DIGEST > image_digest.txt
        displayName: Add release tags to same digest
      - publish: image_digest.txt
        artifact: prod_image

  - job: deploy_prod
    dependsOn: promote_release
    steps:
      - download: current
        artifact: prod_image
      - bash: |
          set -e
          DIGEST=$(cat $(Pipeline.Workspace)/prod_image/image_digest.txt)
          helm upgrade --install ordersvc-prod charts/ordersvc --set image.repository="contoso.azurecr.io/ordersvc" --set image.digest="${DIGEST#*@}"
        displayName: Deploy to Prod by Digest
```

---

## 🧩 What you see at each environment (truth by digest)

- **Dev namespace** is running: `contoso.azurecr.io/ordersvc@sha256:222bbbcccdde...`
- **Staging namespace** is running: `contoso.azurecr.io/ordersvc@sha256:222bbbcccdde...`
- **Prod namespace** is running: `contoso.azurecr.io/ordersvc@sha256:222bbbcccdde...`

> All three point to the _same immutable artifact_. Tags are just convenient labels.

---

## 🗺️ Visual (Mermaid)

```mermaid
flowchart LR
  A[PR #101 build (git-a1b2c3d4)\nsha256:aaa111...] -->|merge| B[Dev build #233 (git-7e4f9a1c)\nsha256:111aaa...]
  C[PR #102 build (git-b2c3d4e5)\nsha256:bbb222...] -->|merge| D[Dev build #234 (git-9a8b7c6d)\nsha256:222bbb...]

  B --> DEV[Deploy Dev by digest 111aaa...]
  D --> DEV2[Deploy Dev by digest 222bbb...]

  D --> RC[Tag 1.4.0-rc.1 on 222bbb...]
  RC --> STG[Deploy Staging by digest 222bbb...]

  STG --> REL[Merge to main: tag 1.4.0,1.4,1,stable on 222bbb...]
  REL --> PROD[Deploy Prod by digest 222bbb...]
```

---

## 🧷 Rollback example (fast & deterministic)

Prod has `sha256:222bbb...` but a bug appears. You want to roll back to the previous release `sha256:111aaa...`.

**One-liner helm (example):**

```bash
helm upgrade --install ordersvc-prod charts/ordersvc \
  --set image.repository="contoso.azurecr.io/ordersvc" \
  --set image.digest="sha256:111aaabbbccc..."
```

No rebuilds, no guessing—just redeploy a known-good digest.

---

## ✅ Key takeaways (why this fits you best)

- Build on **PR→dev** for validation/preview (optional pushes).
- **Build once** on **dev** after merge → this is your canonical candidate.
- PR **dev→main** ⇒ **no rebuild**, tag RC on the **same digest** and validate.
- Merge to **main** ⇒ **no rebuild**, tag release & deploy to prod **by digest**.
- Tags are for humans; **digests** are for deployments. Promotion is moving **labels**, not rebuilding artifacts.

if you tell me your exact stack (ACR/ECR, Helm/Kustomize, admission controls, vulnerability scanner), i’ll tailor the scripts and variables precisely to your environment.
