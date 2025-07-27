# 🏁 Udemy Exam 1

## ❓ Q2

**Q:** True or False? When using the Terraform provider for Vault, the tight integration between these HashiCorp tools provides the ability to mask secrets in the state file.

---

### ✅ Available Options

1. **True**
2. **False**

---

### ❌ Option 1:

**True.**

**Explanation:**
Incorrect. The integration between Terraform and Vault does **not** automatically mask secrets in the Terraform state file.
Secrets written using providers (including Vault) are still stored in plaintext unless **additional secure practices** are used.

---

### ✅ Option 2:

**False.**

**Explanation:**
Correct. The Vault provider does **not inherently mask secrets** in Terraform’s state or plan files.
Sensitive values must be handled through secure design — for example:

- Using environment variables
- Using `sensitive = true`
- Avoiding hardcoded values

---

### 📘 Overall Explanation:

By **default**, Terraform stores **all values — including secrets — in plaintext** within state files and plan outputs.
Even if you use the Vault provider, it will **not automatically mask secrets**.

🔐 To handle secrets securely:

- Use Vault **data sources** to pull secrets at runtime
- **Do not hardcode** secrets in `*.tf` files
- Use `sensitive = true` for outputs
- Store secrets in **environment variables** or CI/CD secrets managers

> 📚 Source: [Terraform + Vault Secrets Management Tutorial](https://learn.hashicorp.com/tutorials/terraform/secrets-vault)

---

## ❓ Q13

**Q:** What are some of the requirements that must be met in order to publish a module on the Terraform Public Registry?
_(Select three)_

---

### ✅ Available Options

1. **Module repositories must use this three-part name format, `terraform-<PROVIDER>-<NAME>`.**
2. **The module must be PCI/HIPPA compliant.**
3. **The module must be on GitHub and must be a public repo.**
4. **The registry uses tags to identify module versions. Release tag names must be in the format `x.y.z`, and can optionally be prefixed with a `v`.**

---

### ✅ Option 1:

**Module repositories must use this three-part name format, `terraform-<PROVIDER>-<NAME>`.**

**Explanation:**
This is a real and required naming convention. It helps categorize modules by provider and function.
✅ Example: `terraform-aws-vpc`, `terraform-google-cloudsql`.

### ❌ Option 2:

**The module must be PCI/HIPPA compliant.**

**Explanation:**
Incorrect. There is **no requirement** for PCI or HIPAA compliance when publishing to the public registry.
Those compliance standards depend on how the module is used, not on publishing.

### ✅ Option 3:

**The module must be on GitHub and must be a public repo.**

**Explanation:**
Correct. The Terraform Public Registry only works with GitHub-hosted **public** repositories.
Private repos or other platforms are not accepted in the **public** registry.

### ✅ Option 4:

**The registry uses tags to identify module versions. Release tag names must be in the format `x.y.z`, and can optionally be prefixed with a `v`.**

**Explanation:**
Correct. Semantic versioning like `1.0.0` or `v0.1.2` is required for module releases to be recognized by the registry.

---

## ❓ Q19

**Q:** When multiple arguments with single-line values appear on consecutive lines at the same nesting level, HashiCorp recommends that you:

---

### ✅ Available Options

1. **Place all arguments using a variable at the top**
2. **Place a space in between each line**
3. **Align the equals signs**
4. **Put arguments in alphabetical order**

---

### ❌ Option 1:

**Place all arguments using a variable at the top.**

**Explanation:**
Incorrect. While using variables can improve maintainability, HashiCorp does **not** recommend placing all variable-based arguments at the top. That’s a personal or team preference, not a style guideline.

---

### ❌ Option 2:

**Place a space in between each line.**

**Explanation:**
Incorrect. Adding blank lines between each argument introduces unnecessary whitespace and reduces compactness. This is **not** part of HashiCorp’s style conventions.

---

### ✅ Option 3:

**Align the equals signs.**

**Explanation:**
✅ Correct! According to HashiCorp's official style conventions, **aligning equal signs** makes Terraform code easier to read and visually consistent.

**Example:**

```hcl
ami           = "abc123"
instance_type = "t2.micro"
subnet_id     = "subnet-a6b9cc2d59cc"
```

Even when argument names vary in length, aligning `=` improves readability.

---

### ❌ Option 4:

**Put arguments in alphabetical order.**

**Explanation:**
Incorrect. Alphabetical ordering is not recommended by HashiCorp and doesn't meaningfully enhance readability or maintenance. The focus is on clarity — not lexicographic order.

---

### 📘 Overall Explanation:

HashiCorp style conventions suggest that **aligning the equal signs** across multiple arguments at the same nesting level improves **readability** and **structure**.

This makes it easier to scan configurations and understand key-value pairs quickly.

> 📚 Source: [Terraform Style Guide – HashiCorp](https://developer.hashicorp.com/terraform/language/syntax/style)

---

## ❓ Q32

**Q:** You are performing a code review of a colleague's Terraform code and see the following code. Where is this module stored?

```ini
module "vault-aws-tgw" {
  source  = "terraform/vault-aws-tgw/hcp"
  version = "1.0.0"

  client_id      = "4djlsn29sdnjk2btk"
  hvn_id         = "a4c9357ead4de"
  route_table_id = "rtb-a221958bc5892eade331"
}
```

---

### ✅ Available Options

1. **In an HCP Terraform private registry**
2. **A local code repository on your network**
3. **In a local file under a directory named `terraform/vault-aws-tgw/hcp`**
4. **The Terraform public registry**

---

### ❌ Option 1:

**In an HCP Terraform private registry.**

**Explanation:**
Incorrect. This format does **not** refer to a private registry.
HCP private registry sources typically use a different URL or Terraform Cloud workspace reference — not just a plain `terraform/<module>/<provider>` style.

---

### ❌ Option 2:

**A local code repository on your network.**

**Explanation:**
Incorrect. If it were local, the `source` would look like a relative path (e.g., `../modules/vault-aws-tgw`) or a full file path.
This format clearly refers to an external module source.

---

### ❌ Option 3:

**In a local file under a directory named `terraform/vault-aws-tgw/hcp`**

**Explanation:**
Incorrect. This path is **not treated as a local directory** because there’s no `./` or `../` prefix.
Terraform interprets this format as a **Terraform Registry** source, not a local path.

---

### ✅ Option 4:

**The Terraform public registry.**

**Explanation:**
✅ Correct!
This `source = "terraform/vault-aws-tgw/hcp"` is the standard format for modules stored in the **Terraform Public Registry**.

The format is:

```ini
<namespace>/<name>/<provider>
```

Which in this case is:

- `terraform` = namespace
- `vault-aws-tgw` = module name
- `hcp` = provider

---

### 📘 Overall Explanation:

Terraform modules hosted on the **Terraform Public Registry** use a standardized naming format:

```ini
source  = "<NAMESPACE>/<MODULE_NAME>/<PROVIDER>"
version = "x.y.z"
```

✅ Example:

```ini
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.14.0"
}
```

📦 This format tells Terraform to fetch the module from the **official public registry**, not from GitHub directly or a local file.

📘 For more info, see the [Terraform Modules Documentation](https://www.terraform.io/docs/configuration/modules.html)

---
