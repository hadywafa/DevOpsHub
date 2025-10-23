# 🎙️ **Transcript-Style Answer**

> **Sure!**
> In our current setup, we’re running a complete GitOps-driven CI/CD pipeline for our microservices hosted on **AWS EKS**.
>
> We use **Terraform** for provisioning the infrastructure — it creates our EKS cluster across **multiple Availability Zones** for high availability, sets up node groups, VPC, subnets, load balancer controller, autoscaler, Prometheus stack, Argo CD, and all the core addons we need.
>
> The cluster is spread across three AZs, and we’ve configured both **pod-level autoscaling** using Horizontal Pod Autoscaler and **cluster-level scaling** using the Cluster Autoscaler. We’re also planning to add **KEDA** soon for event-driven scaling based on RabbitMQ message queues — that’s currently in progress.

---

## 🧩 **How Our CI/CD Flow Works**

> We actually have **two separate repositories** — one for the **application code**, and another for **Kubernetes manifests** (we call it the infra or k8s repo).
>
> So, in the **apps repo**, we define the source code, Dockerfile, tests, and CI workflows using **GitHub Actions**.
>
> Whenever we push to `main` or `dev`, GitHub Actions triggers the pipeline.
>
> The pipeline runs a few key steps in order:

---

## 🔍 **1. Code Quality and Security Checks**

> First, we run **SonarQube** to analyze code quality and enforce our quality gates.
> It checks for bugs, code smells, and coverage thresholds — so if the code doesn’t meet our internal standards, the pipeline fails early.
>
> Then we run **Trivy** twice —
> first for a **filesystem scan** to catch vulnerable dependencies before building,
> and then again after the image is built for an **image vulnerability scan**.
>
> This ensures the image we push is free of any high or critical CVEs.

---

### 🏗️ **2. Build and Tag the Image**

> After that, we build the Docker image and tag it in a very traceable way.
>
> The tag format we use is something like `1.4.2-<shortSHA>` —
> so it combines the version and the Git commit hash, which makes every build unique and immutable.
>
> Once it’s built, we push it to **GitHub Container Registry (GHCR)**.
>
> Using GHCR works nicely for us because it integrates directly with GitHub Actions,
> and we can manage fine-grained permissions per repository.

---

### 🔄 **3. Updating the Kubernetes Manifests**

> Now comes the key GitOps step.
> After the image is successfully pushed, the pipeline **clones the Kubernetes repo** —
> updates the `values.yaml` file of that service with the new image tag,
> and commits that change.
>
> If it’s a `dev` build, it pushes directly to the `dev` branch.
> Our **Argo CD** instance automatically detects that change, pulls the updated manifest, and applies it to the **EKS cluster**.
>
> So, deployment to the dev environment happens automatically.

---

### 🔒 **4. Controlled Deployment to Production**

> For the **main branch** or production releases, the pipeline doesn’t deploy directly.
>
> Instead, it opens a **Pull Request** in the k8s repo targeting the `main` branch, updating the image tag in the prod values file.
>
> That PR has to be **reviewed and approved** by a lead or DevOps engineer.
> Once it’s merged, **Argo CD** detects the change on the main branch and automatically syncs it to the production cluster.
>
> This gives us a **controlled promotion model** — the same image that passed all checks in dev is what goes to prod, with human approval in between.

---

### 🚀 **5. Argo CD and Helm**

> Inside the cluster, Argo CD deploys everything using **Helm charts**.
>
> Each environment has its own values file, so it’s easy to manage differences like replicas, resources, or secrets.
>
> The pull-based model is very secure — Argo pulls changes from Git;
> we don’t push anything directly into the cluster, so we never expose credentials or kubeconfigs in our pipelines.

---

### ⚙️ **6. Scaling and Reliability**

> On the reliability side —
> our EKS cluster is **multi-AZ** for fault tolerance.
>
> We use **HPA** to scale pods automatically based on CPU or memory,
> and the **Cluster Autoscaler** adds or removes nodes as needed.
>
> Once we finish implementing **KEDA**, our background workers will also scale automatically based on RabbitMQ queue length,
> so even event-driven workloads scale seamlessly.

---

### 📊 **7. Monitoring and Observability**

> For monitoring, we’ve integrated **Prometheus** and **Grafana** using the kube-prometheus-stack Helm chart.
>
> We have custom dashboards for workloads, cluster metrics, and latency per service.
>
> And all logs are shipped to **AWS CloudWatch** via Fluent Bit, so we can correlate metrics, logs, and alerts in one place.
>
> We also have alerts from Grafana and CloudWatch routed to Slack for real-time notifications.

---

### 🔐 **8. Security and Access Control**

> On the security side, we strictly follow the **least privilege** principle:
>
> - All AWS access for CI/CD happens via **GitHub OIDC → IAM roles** (no long-lived keys).
> - Each Kubernetes component — Argo, Autoscaler, Load Balancer Controller — runs with its own **IRSA role**.
> - GHCR pull secrets are read-only, scoped per namespace.
>
> Everything from build to deploy is fully auditable because all promotions happen through **Git commits and PRs**.

---

## 🧩 **Final Summary (wrap-up sentence)**

> So, in short —
> our CI/CD pipeline builds and scans the code in **GitHub Actions**,
> pushes a versioned image to **GHCR**,
> then updates the **Kubernetes manifests** automatically in the k8s repo.
>
> **Argo CD** picks those changes and applies them to the EKS cluster using **Helm**,
> ensuring a full **GitOps workflow** with security, automation, and auditability at every stage.
