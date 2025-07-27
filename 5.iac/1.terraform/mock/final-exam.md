# Questions

---

## ✅ 1. What happens if you manually delete a resource from the cloud console and then run `terraform apply`?

### 🧠 Answer:

If you **delete a resource manually** from the cloud console (e.g., AWS Console), but **Terraform still has it in the `.tfstate` file**, then:

- When you run `terraform plan` or `terraform apply`, Terraform **detects that the resource no longer exists** and will attempt to **recreate it**.

### ✅ Terraform behavior:

- **No error** will be thrown.
- It will **plan to recreate** the missing resource (unless `lifecycle.prevent_destroy` is set).
- It will show something like:

```bash
-/+ resource "aws_instance" "web" {
      # instance was deleted manually
    + recreate...
}
```

### 📌 Example:

```hcl
resource "aws_instance" "web" {
  ami           = "ami-0abcdef1234567890"
  instance_type = "t2.micro"
}
```

If you go to AWS Console and delete this EC2 manually, and then run:

```bash
terraform apply
```

Terraform will recreate the instance.

> ⚠️ But remember: any **drifted data** (e.g., tags, IPs) may differ unless managed explicitly.

---

## ✅ 2. Is `terraform init -upgrade` used to update provider versions?

### 🧠 Answer: YES!

```bash
terraform init -upgrade
```

This command tells Terraform to:

- **Re-check all required providers**.
- **Upgrade** to the **newest acceptable version** **within the version constraints** in your `.tf` files.

---

### ✅ Example:

If you have:

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"   # allows upgrades up to <6.0
    }
  }
}
```

Running:

```bash
terraform init -upgrade
```

Will upgrade AWS provider from `5.3.0` → `5.32.0` if available.

---

### 🔧 Use Cases:

- When you change version constraints
- When you clone someone else's project and want to get the latest compatible providers
- When you want to force-check for newer provider/plugin versions

---

### 🔥 Bonus Tip:

You can force a version upgrade manually too:

```bash
terraform providers lock -platform=linux_amd64
```

And remove `.terraform.lock.hcl` if needed (but not recommended casually).

---

### 🛑 Don't confuse with:

- `terraform apply` — applies the plan, doesn't upgrade
- `terraform version` — shows your Terraform binary version, not the provider

---

Excellent follow-up questions! Let's go through each one in a clean, structured, and complete way:

---

## ✅ 3. Do all Terraform backends support state locking?

### 🧠 Answer: **Not all**, only **some backends** support state locking.

---

### 🔒 State Locking Overview:

**State locking** prevents **race conditions** when multiple users or processes try to update the same `terraform.tfstate` file.

---

### ✅ Backends that support locking:

| Backend                 | Supports Locking | Notes                                             |
| ----------------------- | ---------------- | ------------------------------------------------- |
| `s3` + `DynamoDB`       | ✅ Yes           | Requires extra setup (DynamoDB table) for locking |
| `azurerm`               | ✅ Yes           | Uses blob leases for lock                         |
| `gcs`                   | ✅ Yes           | Uses GCS object locks                             |
| `consul`                | ✅ Yes           | Built-in lock mechanism                           |
| `http`                  | ✅ (optional)    | If lock/unlock endpoints are implemented          |
| `terraform cloud / HCP` | ✅ Yes           | Automatic lock built-in                           |

---

### ❌ Backends **without** locking:

| Backend       | Notes                                |
| ------------- | ------------------------------------ |
| `local`       | ❌ No locking — risky for team usage |
| `remote-exec` | ❌ Not relevant                      |
| `file`        | ❌ Deprecated, no locking            |

---

### 🔥 Best Practice:

> **Always use locking** in team environments to prevent state corruption.

---

## ✅ 4. For sharing Terraform modules, what criteria should be followed?

### 🧠 Answer: Modules should be **versioned**, **documented**, and follow **naming conventions**.

---

### ✅ Key Criteria for Sharing Modules:

| Criteria                     | Description                                                            |
| ---------------------------- | ---------------------------------------------------------------------- |
| ✅ **Semantic Versioning**   | Use versions like `v1.0.0`, `v1.2.3`. Required for Terraform Registry  |
| ✅ **Proper Inputs/Outputs** | Use `variables.tf` and `outputs.tf` clearly                            |
| ✅ **Reusability**           | Avoid hardcoded values, make the module configurable                   |
| ✅ **Documentation**         | Add `README.md` with usage examples                                    |
| ✅ **Naming Convention**     | Follow pattern: `terraform-<PROVIDER>-<NAME>` e.g. `terraform-aws-vpc` |
| ✅ **Registry Metadata**     | Add `versions.tf` with required Terraform and provider versions        |

---

### 📦 Example module layout:

```
terraform-aws-vpc/
├── main.tf
├── variables.tf
├── outputs.tf
├── README.md
├── versions.tf
```

---

### 🔗 Registry Requirements:

To publish on [registry.terraform.io](https://registry.terraform.io), follow:

- Repo must be public on GitHub
- Repo name must start with `terraform-`
- You must tag releases (`git tag v1.0.0`)

---

## ✅ 5. Is Terraform HCP web-based or local?

### 🧠 Answer: **Terraform HCP (Cloud/Enterprise)** is a **web-based SaaS** solution.

---

### 🔍 Details:

| Aspect        | Terraform HCP (Cloud/Enterprise)                                             |
| ------------- | ---------------------------------------------------------------------------- |
| Web-based UI? | ✅ Yes — Fully managed GUI                                                   |
| CLI Access?   | ✅ Yes — via `terraform` CLI using the `remote` backend                      |
| Runs Locally? | ❌ No — workloads are executed remotely in HCP’s infra (unless using agents) |
| Self-hosted?  | ❌ HCP = SaaS. Terraform Enterprise = self-hosted option                     |

---

### 🔥 Note:

Terraform CLI **can still run locally** — it just **connects to HCP** to store state, run plans, manage workspaces, etc.

---

## ✅ 6. What happens when you commit or merge to a branch connected to Terraform HCP?

### 🧠 Answer: Terraform HCP **automatically triggers a Plan** if it's connected to **VCS Integration** (like GitHub).

---

### ✅ Behavior when pushing to Git:

| Event                                  | Action by Terraform Cloud/HCP                    |
| -------------------------------------- | ------------------------------------------------ |
| `git push` / `merge` to watched branch | ✅ Triggers a new **Terraform Plan**             |
| Manual review or auto-approve          | ✅ You can review the plan and **apply**         |
| CI/CD integration                      | ✅ You can gate it behind approvals or pipelines |

---

### ✅ VCS Integration Examples:

- **Supported VCS**:

  - GitHub / GitHub Enterprise
  - GitLab
  - Bitbucket
  - Azure Repos

- **Branch Watching**:

  - You configure which **branch** triggers the plan
  - Optional auto-apply flag

---

### 🔄 Typical Flow:

1. Developer commits to `main` or `dev` branch
2. HCP detects VCS webhook trigger
3. Runs `terraform plan` automatically
4. Optionally auto-applies, or waits for manual approval

---

### 🧠 Pro Tip:

> You can connect your Terraform workspace to your repo via **VCS provider settings**, and you can restrict:
>
> - Auto-apply vs. manual apply
> - Plan only on specific branches or paths
> - Notifications via Slack/email

---

Let me know if you want a visual workflow diagram for Terraform HCP + GitHub CI/CD pipeline!
