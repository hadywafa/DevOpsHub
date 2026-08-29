# 1. GitLab CI/CD architecture

Mental model:

```text
.gitlab-ci.yml
      ↓
Pipeline
      ↓
Stages
      ↓
Jobs
      ↓
Runner
      ↓
Executor
      ↓
Shell / Docker / Kubernetes
```

Core definitions:

|Concept|Meaning|
|---|---|
|Pipeline|Complete CI/CD execution|
|Stage|Logical grouping/order|
|Job|Individual unit of execution|
|Runner|Agent that accepts and executes jobs|
|Executor|How the runner executes jobs|
|`script:`|Commands executed by the job|
|`image:`|Runtime container image|
|`tags:`|Runner-selection labels|

Important behavior:

```text
Stages → sequential by default

Jobs in same stage → parallel by default
```

GitLab normally checks out the repository automatically, unlike GitHub Actions where you commonly use `actions/checkout`.

Strong interview answer:

> GitLab separates the control plane from execution. GitLab parses `.gitlab-ci.yml`, creates and schedules the pipeline, while GitLab Runner executes jobs using an executor such as Shell, Docker, or Kubernetes.

---

## 2. `workflow:rules` vs job `rules`

This is one of the most important GitLab concepts.

```text
workflow:rules
      ↓
Should the PIPELINE exist?

job rules:
      ↓
Should this JOB exist inside the pipeline?
```

Example:

```yaml
workflow:
  rules:
    - if: '$CI_PIPELINE_SOURCE == "merge_request_event"'
    - if: '$CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH'
    - if: '$CI_COMMIT_TAG'
    - when: never
```

Then:

```yaml
deploy-prod:
  rules:
    - if: '$CI_COMMIT_TAG'
      when: manual
```

Rules are:

> evaluated top-to-bottom, and the first matching rule wins.

Important variables:

```text
CI_PIPELINE_SOURCE
CI_COMMIT_BRANCH
CI_COMMIT_TAG
CI_DEFAULT_BRANCH
CI_MERGE_REQUEST_ID
```

Important pipeline sources:

```text
push
merge_request_event
schedule
web
api
trigger
parent_pipeline
pipeline
```

Interview answer:

> I use `workflow:rules` to control pipeline creation and job-level `rules` to control individual jobs. I also use `CI_PIPELINE_SOURCE` because branch and trigger type are separate concerns.

---

## 3. `rules:changes` and `rules:exists`

Very useful in monorepos.

Run only if files changed:

```yaml
terraform-plan:
  rules:
    - changes:
        - terraform/**/*
```

Run if a file exists:

```yaml
maven-build:
  rules:
    - exists:
        - pom.xml
```

Use case:

```text
frontend change
   ↓
only frontend pipeline

terraform change
   ↓
only Terraform jobs
```

Senior point:

> In large monorepos, I avoid running the full pipeline for every commit. I combine `rules:changes`, DAG dependencies, and sometimes child pipelines to limit execution to affected components.

---

## 4. Variables

Variable locations include:

```text
YAML
job-level
project
group
instance
pipeline/manual variables
dotenv
predefined GitLab variables
```

Important principle:

> Variable precedence matters. A variable defined closer to the job does not automatically mean it has the highest precedence.

Also:

```text
CI_* variables
```

should generally be treated as GitLab-owned predefined variables.

### Inputs vs variables

For reusable components:

```text
spec:inputs
    ↓
configuration / parameters

variables
    ↓
runtime values

secret manager / protected variables
    ↓
secrets
```

Strong answer:

> I use typed inputs for reusable template configuration and variables for runtime values. For secrets, I prefer protected variables or an external secrets provider rather than treating inputs as secret storage.

---

## 5. DAG pipelines and `needs`

Normal stage pipeline:

```text
BUILD
  ↓
TEST
  ↓
SECURITY
  ↓
DEPLOY
```

Problem:

Every stage waits for the entire previous stage.

With:

```yaml
test-api:
  needs:
    - build-api
```

you get:

```text
build-api ─────► test-api

build-ui ───────────────► ...
```

So `test-api` doesn't wait for unrelated jobs.

Key distinction:

```text
stage:
    logical organization

needs:
    real dependency graph
```

Interview answer:

> Stages create synchronization barriers. I use `needs` to model the real DAG so jobs start as soon as their actual prerequisites finish, which shortens the critical path.

---

## 6. Artifacts vs cache

This is a common interview question.

### Artifact

Output of a job:

```text
JAR
WAR
binary
test report
Terraform plan
compiled frontend
```

Example:

```yaml
artifacts:
  paths:
    - target/app.jar
```

### Cache

Performance optimization:

```text
Maven repository
npm cache
pip cache
Gradle cache
```

Example:

```yaml
cache:
  paths:
    - .m2/repository/
```

The best rule:

> If cache disappears, the pipeline should normally still work, just slower.

Artifacts can be required for correctness.

Strong answer:

> Artifacts pass job outputs downstream, while cache reduces repeated dependency downloads. I never rely on cache as the authoritative build output.

---

## 7. `needs:artifacts`

Example:

```yaml
docker-build:
  needs:
    - job: build
      artifacts: true
```

This says:

```text
Wait for build
+
download its artifacts
```

You can also use:

```yaml
artifacts: false
```

when you need the dependency relationship but not its files.

Important:

When using DAG `needs`, artifact behavior becomes more explicit than traditional stage-based artifact downloading.

---

## 8. `dependencies` vs `needs`

Older pipelines may use:

```yaml
dependencies:
  - build
```

`dependencies` mostly controls:

```text
which previous-stage artifacts to download
```

It does not create the same DAG scheduling relationship.

For modern DAG pipelines:

> Prefer `needs` and `needs:artifacts`.

---

## 9. `needs:optional`

Useful when a job might not exist because of `rules`.

```yaml
deploy:
  needs:
    - job: security
      optional: true
```

Meaning:

```text
security exists?
  yes → wait for it

security does not exist?
  → continue
```

This prevents pipeline creation errors with conditional jobs.

---

## 10. Parallel jobs

Simple:

```yaml
test:
  parallel: 4
```

creates:

```text
test 1/4
test 2/4
test 3/4
test 4/4
```

Matrix:

```yaml
test:
  parallel:
    matrix:
      - JAVA: ["21", "25"]
        OS: ["ubuntu", "alpine"]
```

creates:

```text
Java21 Ubuntu
Java21 Alpine
Java25 Ubuntu
Java25 Alpine
```

Use cases:

```text
multi-cloud Terraform
multiple Java versions
multiple OS/architecture combinations
integration-test sharding
```

---

## 11. `include`

`include` means:

> Import configuration and merge it into the current pipeline.

Types you should know:

```text
include:local
include:project
include:remote
include:template
include:component
```

Important:

```text
include
≠
new pipeline
```

It is configuration composition.

---

# 12. `extends`

Reusable job inheritance.

```yaml
.maven:
  image: maven:3.9
  cache:
    paths:
      - .m2/

build:
  extends: .maven
  script:
    - mvn package
```

Hidden jobs start with:

```text
.
```

and don't execute directly.

Important limitation:

> Maps/hashes merge, but arrays such as `script` don't automatically append.

So:

```yaml
.base:
  script:
    - one

job:
  extends: .base
  script:
    - two
```

doesn't give:

```text
one
two
```

It effectively replaces the script.

---

## 13. `!reference`

Use when you want to reuse a particular configuration fragment instead of inheriting an entire job.

Mental model:

```text
extends
    ↓
inherit job configuration

!reference
    ↓
reuse selected section
```

I would generally prefer:

```text
extends
include
inputs
```

over overly complicated YAML anchors.

---

## 14. CI/CD Components

Think:

```text
GitHub Action / reusable workflow
        ≈
GitLab CI/CD Component
```

Example consumption:

```yaml
include:
  - component: $CI_SERVER_FQDN/platform/components/maven@2.3.1
    inputs:
      java-version: "21"
```

Good components expose a small interface:

```text
java-version
environment
Dockerfile
namespace
```

while hiding:

```text
proxy config
cache implementation
runner selection
security implementation
registry authentication
company standards
```

Senior-level principle:

> Platform teams should provide versioned reusable capabilities rather than forcing application teams to maintain hundreds of lines of CI YAML.

---

## 15. Component versioning

Treat CI components like software:

```text
1.2.3

Major → breaking
Minor → compatible new feature
Patch → fix
```

Prefer:

```text
component@2.3.1
```

over constantly consuming:

```text
main
latest
```

for critical pipelines.

This gives controlled rollout across repositories.

---

## 16. Components vs policies

Very important:

```text
Component
    ↓
developer CHOOSES to use reusable functionality

Pipeline Execution Policy
    ↓
organization ENFORCES functionality
```

Example:

```text
Maven component
Docker component
Helm component
```

are reusable capabilities.

But:

```text
mandatory SAST
secret scanning
compliance validation
```

may be centrally enforced using policy.

---

## 17. Parent-child pipelines

Same project.

Example monorepo:

```text
repo
├── frontend
├── backend
└── terraform
```

Parent:

```text
Parent Pipeline
   │
   ├────► Frontend Child
   ├────► Backend Child
   └────► Terraform Child
```

Syntax:

```yaml
backend:
  trigger:
    include:
      - local: backend.yml
    strategy: mirror
```

Inside child:

```text
CI_PIPELINE_SOURCE=parent_pipeline
```

Use for:

> decomposing large pipelines or monorepos.

---

## 18. `strategy: mirror`

Default trigger behavior can succeed once the downstream pipeline is created.

With:

```yaml
strategy: mirror
```

the trigger waits for and mirrors downstream status.

```text
Child passes
   ↓
Trigger passes

Child fails
   ↓
Trigger fails
```

Use when the parent must care about downstream success.

---

## 19. Dynamic child pipelines

A pipeline can generate another pipeline's YAML.

```text
generate job
     ↓
generated-ci.yml
     ↓
trigger
     ↓
dynamic child pipeline
```

Useful for:

```text
very large monorepos
service discovery
dynamic infrastructure combinations
generated CI graphs
```

But:

> Don't use dynamic YAML when static YAML is sufficient.

Complexity becomes difficult to debug.

---

## 20. Multi-project pipelines

Different GitLab projects.

```text
payment-api
     ↓
deployment-platform
```

Syntax:

```yaml
deploy:
  trigger:
    project: platform/deployments
    strategy: mirror
```

Inside the downstream pipeline:

```text
CI_PIPELINE_SOURCE=pipeline
```

Use when coordinating:

```text
separate microservices
deployment repositories
separate ownership boundaries
release orchestration
```

---

## 21. Parent-child vs multi-project

Easy rule:

```text
same project / same commit
      ↓
parent-child

different project
      ↓
multi-project
```

Interview answer:

> Parent-child pipelines are best for decomposing one repository, particularly monorepos. Multi-project pipelines orchestrate independently versioned GitLab projects.

---

## 22. Cross-pipeline artifacts

Parent-child:

```text
needs:pipeline:job
```

Cross-project:

```text
needs:project
```

Important nuance:

> `needs:project` is primarily cross-project artifact retrieval. Don't assume it behaves exactly like normal same-pipeline DAG `needs`.

Cross-project permissions and `CI_JOB_TOKEN` allowlists matter.

---

## 23. Runner scopes

Three scopes:

```text
Instance Runner
Group Runner
Project Runner
```

Use:

```text
Instance
→ broadly shared

Group
→ shared across a team/business domain

Project
→ specialized project requirements
```

For enterprise use, Group Runners are often a good balance.

---

## 24. Runner vs Executor

Memorize this answer:

> GitLab Runner is the agent process communicating with GitLab and accepting jobs. The executor defines how jobs run, such as directly on the host with Shell, in Docker containers, or in Kubernetes Pods.

Architecture:

```text
GitLab
   ↓
Runner Manager
   ↓
Executor
```

---

## 25. Main executors

### Shell

```text
Runner VM
   ↓
  bash
```

Pros:

```text
simple
fast
special tooling
```

Cons:

```text
weak isolation
persistent contamination
```

Use only for trusted workloads.

---

### Docker

```text
Runner
   ↓
Docker
   ↓
job container
```

Better isolation and repeatability.

---

### Kubernetes

```text
Runner Manager Pod
       ↓
Kubernetes API
       ↓
temporary Job Pod
       ├── build container
       ├── helper container
       └── service containers
```

This is the architecture you should know very well.

---

## 26. Kubernetes executor internals

### Build container

Runs:

```yaml
script:
```

### Helper container

GitLab Runner plumbing, such as repository/artifact/cache-related operations.

### Services

Examples:

```text
PostgreSQL
Redis
Kafka
```

for tests.

The job Pod is generally temporary and removed after execution.

---

## 27. Runner concurrency

Do not confuse:

```text
concurrent
limit
request_concurrency
```

### `concurrent`

Maximum jobs across the Runner process.

### `limit`

Maximum jobs for a specific runner configuration.

### `request_concurrency`

How many concurrent requests that runner makes to GitLab to acquire jobs.

Interview answer:

> `concurrent` controls global Runner process execution capacity, `limit` constrains an individual runner definition, and `request_concurrency` controls job-request parallelism rather than job execution.

---

## 28. Secure runner architecture

Don't make:

```text
one runner
privileged
prod access
all repositories
```

Better:

```text
General CI runners
   ↓
build/test
no PROD access

Container build runners
   ↓
special image-build permissions

Production deploy runners
   ↓
protected
limited projects
production network
strong identity
```

Separate by:

```text
trust boundary
network
privilege
workload type
```

not merely convenience.

---

## 29. Protected runners

Useful for production workloads.

```text
Protected runner
    ↓
protected branch/tag jobs only
```

Use with:

```text
protected variables
protected environments
protected refs
```

to build multiple security boundaries.

---

## 30. Docker build security

Avoid casually mounting:

```text
/var/run/docker.sock
```

into shared CI containers.

Why?

Because Docker socket access can effectively become host-level access.

DinD:

```text
docker CLI
   ↓
docker:dind service
```

is another option but often requires privileged mode.

For modern Kubernetes CI, evaluate:

```text
rootless BuildKit
Buildah
Podman
other daemonless approaches
```

depending on environment.

---

## 31. Environments

Example:

```yaml
environment:
  name: production
```

Environment = deployment target.

Examples:

```text
development
staging
production
review/*
```

Deployment = specific version delivered to that environment.

---

## 32. Review Apps

Temporary environment per MR/branch.

```text
MR
 ↓
build
 ↓
deploy
 ↓
review/feature-login
 ↓
temporary URL
```

Use:

```yaml
environment:
  name: review/$CI_COMMIT_REF_SLUG
  on_stop: stop-review
  auto_stop_in: 2 days
```

Excellent for frontend/web application testing.

---

## 33. Protected environments

Protected branches answer:

```text
Who can modify main?
```

Protected environments answer:

```text
Who can deploy production?
```

For PROD, use both.

Also consider:

```text
deployment approvals
```

when a separate approval is required.

---

## 34. `resource_group`

This is important for production.

```yaml
deploy-prod:
  resource_group: production
```

Meaning:

> Only one job holding the `production` resource lock can execute at a time.

Think:

```text
mutex(production)
```

This prevents:

```text
pipeline A deploy
pipeline B deploy
pipeline C deploy
```

running concurrently against the same target.

Interview answer:

> I use `resource_group` to serialize deployments to shared environments and avoid race conditions across concurrent pipelines.

---

## 35. Push CD vs GitOps

### Push CD

```text
GitLab Runner
     ↓
kubectl / helm
     ↓
Kubernetes API
```

CI has direct production access.

### GitOps

```text
CI
 ↓
publish image
 ↓
update desired state
 ↓
Git
 ↓
Flux
 ↓
Kubernetes
```

GitOps gives:

```text
desired-state history
reconciliation
drift remediation
stronger CI/production separation
```

Strong interview answer:

> In push-based CD, CI actively deploys to Kubernetes. In GitOps, Git stores desired state and an in-cluster reconciler such as Flux continuously converges the cluster toward it.

---

## 36. GitLab Agent for Kubernetes

Architecture:

```text
GitLab
   ↓
GitLab Relay/KAS
   ↓
agentk
   ↓
Kubernetes
```

The agent typically establishes an outbound connection from the cluster.

Useful for private Kubernetes clusters.

Remember:

```text
GitLab Agent
≠
automatically GitOps
```

It can be used for:

```text
CI-driven Kubernetes access
or
Flux-based GitOps
```

---

## 37. CI/CD security variables

For sensitive GitLab variables, know:

```text
Masked
Hidden
Protected
Environment scoped
File type
```

Important:

> Masking only prevents accidental log exposure. It does not stop malicious CI code from exfiltrating the secret.

Therefore combine secrets with:

```text
protected refs
MR reviews
runner restrictions
environment controls
short-lived identities
```

---

## 38. `CI_JOB_TOKEN`

Extremely important.

Automatically created for each job.

Properties:

```text
short-lived
GitLab-specific
limited API/resource access
revoked after job
```

Use for:

```text
GitLab → GitLab CI interactions
artifacts
packages
repositories
allowed cross-project access
```

Prefer it over storing a PAT whenever supported.

---

## 39. Job token allowlist

Cross-project:

```text
Project B CI
     ↓
access Project A
```

Project A can allowlist B.

Security model:

```text
B allowlisted
+
triggering user has required access
```

Then job token access can succeed.

This is important for:

```text
multi-project pipelines
cross-project artifacts
central components/packages
```

---

## 40. Token decision model

Memorize:

```text
CI needs GitLab resource
        ↓
CI_JOB_TOKEN

Persistent automation in one project
        ↓
Project Access Token

Persistent group automation
        ↓
Group Access Token carefully

Registry/package external access
        ↓
Deploy Token

Human/API automation
        ↓
PAT

Runner authentication
        ↓
Runner authentication token
```

Avoid using a personal PAT for every automation.

---

## 41. OIDC

This is probably the strongest security subject for your interview.

Traditional:

```text
GitLab
  ↓
stored AZURE_CLIENT_SECRET
  ↓
Azure
```

Modern:

```text
GitLab Job
   ↓
short-lived OIDC JWT
   ↓
Microsoft Entra / AWS STS / Vault
   ↓
temporary credentials
```

GitLab:

```yaml
id_tokens:
  AZURE_OIDC_TOKEN:
    aud: ...
```

Benefits:

```text
no long-lived cloud secret
short-lived credential
identity can include project/ref
better auditing
smaller blast radius
```

---

## 42. OIDC vs `CI_JOB_TOKEN`

Do not confuse:

```text
CI_JOB_TOKEN
     ↓
authenticate to GitLab


OIDC ID token
     ↓
authenticate GitLab workload to Azure/AWS/Vault/etc.
```

Example:

```text
Download GitLab artifact
      ↓
CI_JOB_TOKEN

Login to Azure
      ↓
OIDC
```

---

## 43. Senior-level secrets architecture

This is worth memorizing exactly:

```text
Non-sensitive pipeline configuration
      ↓
inputs / variables

GitLab-to-GitLab authentication
      ↓
CI_JOB_TOKEN

Cloud authentication
      ↓
OIDC

Application/runtime secrets
      ↓
Key Vault / Vault

Long-lived API token
      ↓
only when unavoidable
```

This is a very strong interview answer.

---

## 44. Security scanning

Know these categories:

```text
SAST
Dependency Scanning
Secret Detection
Container Scanning
IaC Scanning
DAST
```

Mental model:

```text
Source
 ├── SAST
 ├── secret detection
 └── dependency scanning

Build image
      ↓
container scanning

Running application
      ↓
DAST
```

Reports can be understood by GitLab rather than just stored as generic artifacts.

---

## 45. Pipeline Execution Policies

For centralized enforcement:

```text
Security Team
      ↓
Policy
      ↓
500 repositories
      ↓
mandatory jobs
```

Use for:

```text
SAST
secret detection
compliance checks
custom security jobs
```

Difference:

```text
component
=
standard reusable capability

policy
=
mandatory organizational control
```

This is a very important senior-level distinction.

---

## 46. The complete enterprise pipeline example

If they ask:

**"How would you design a production GitLab CI/CD pipeline?"**

You can describe:

```text
                    Merge Request
                         │
       ┌─────────────────┼─────────────────┐
       │                 │                 │
      SAST          Secret Scan       Dependency Scan
       │                 │                 │
       └─────────────────┼─────────────────┘
                         ▼
                       Build
                         │
                         ▼
                      Unit Test
                         │
                         ▼
                    Build Image
                         │
                         ▼
                   Container Scan
                         │
                         ▼
                       Harbor
                         │
                         ▼
                Deploy DEV automatically
                         │
                         ▼
                    Smoke / E2E
                         │
                         ▼
                  PROD Promotion
                         │
            ┌────────────┼────────────┐
            │            │            │
       Protected     Approval    resource_group
       Environment
            │
            ▼
       OIDC identity
            │
            ▼
         AKS / GitOps
```

And underneath:

```text
Reusable CI Components
        ↓
common implementation

Pipeline Execution Policies
        ↓
mandatory security controls

Kubernetes Runner fleet
        ↓
isolated execution

CI_JOB_TOKEN
        ↓
GitLab authentication

OIDC
        ↓
cloud authentication
```

That is a solid **Senior DevOps Engineer architecture answer**.

---

## 47. Top 15 questions I would expect

You should be able to answer these comfortably:

1. **What is the difference between `workflow:rules` and job `rules`?**
    
2. **What is `CI_PIPELINE_SOURCE` and why would you use it?**
    
3. **What is the difference between stages and `needs`?**
    
4. **Artifacts vs cache?**
    
5. **`needs` vs `dependencies`?**
    
6. **How would you optimize a slow GitLab pipeline?**
    
7. **How do reusable templates/components work?**
    
8. **`include` vs `extends`?**
    
9. **Child pipeline vs multi-project pipeline?**
    
10. **What does `strategy: mirror` do?**
    
11. **Runner vs executor?**
    
12. **How does the Kubernetes executor work?**
    
13. **How would you secure production GitLab runners?**
    
14. **`CI_JOB_TOKEN` vs PAT vs OIDC?**
    
15. **How would you design production deployment controls?**
    

If you can answer those well, you're in good shape for most Senior DevOps GitLab discussions.

---

## 48. Five things to emphasize as a Senior Engineer

Don't only talk about syntax.

Keep bringing the discussion back to these:

```text
1. Performance
   DAG, cache, parallelism

2. Reusability
   components, inputs, versioning

3. Scalability
   runner fleets, autoscaling, monorepos

4. Security
   OIDC, protected runners, policies, least privilege

5. Governance
   centralized components + enforcement policies
```

That's what separates:

```text
"I know GitLab YAML"
```

from:

```text
"I can design and operate GitLab CI/CD as a platform."
```

For your interview, that second impression is what you want.