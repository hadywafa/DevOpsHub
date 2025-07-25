# ✅ Terraform Module Refactoring Review & Best Practices

## 🧱 Project Structure Review

You’ve split your project into:

```ini
modules/
  └─ vpc-module/
  └─ web-server-module/
scripts/
main.tf
providers.tf
variables.tf
terraform.tfvars
outputs.tf
```

➖ This is a **great separation of concerns**:

- `modules/` for reusable infra blocks.
- `main.tf` at root for composition.
- `scripts/` for provisioning logic like `user_data`.

---

## 🔁 Repetition of Variables: Do We Need This?

Yes, **you must define variables** in both:

1. The **module itself** (e.g., `modules/web-server-module/variables.tf`)
2. The **root level** to pass values to that module.

### Why?

Terraform modules are isolated. Each module is a mini-Terraform project with its own interface.

➖ So this repetition is **mandatory**, but...

### 🧼 You Can DRY It a Bit:

If some variables are shared across all modules (e.g., `env_prefix`, `availability_zone`), consider:

- Declaring them as shared variables at root level.
- Using a wrapper module pattern (advanced reuse).

---

## ✨ Recommendations & Enhancements

### 1. ✅ Validate Required Variables

Add `type` and `description` to all `variable` blocks:

```hcl
variable "env_prefix" {
  type        = string
  description = "Environment name (e.g., dev, prod)"
}
```

### 2. ✅ Avoid Hardcoding AMI ID

You're currently using:

```hcl
ami = "ami-07c8c1b18ca66bb07"
```

Use the dynamic `data` block instead:

```hcl
ami = data.aws_ami.ubuntu_latest.id
```

And expose `ami_id` as an input to make it overrideable if needed.

---

### 3. ✅ Input Validation via `variables.tf`

Use `validation` blocks for safety:

```hcl
variable "instance_type" {
  type        = string
  default     = "t3.micro"
  description = "EC2 instance type"

  validation {
    condition     = contains(["t2.micro", "t3.micro"], var.instance_type)
    error_message = "Only t2.micro or t3.micro are allowed."
  }
}
```

---

### 4. ✅ Separate Data Sources from Resources

Move this to a dedicated `data.tf` (optional, but improves clarity):

```hcl
data "aws_ami" "ubuntu_latest" {
  ...
}
```

---

### 5. ✅ Use `locals.tf` (Optional)

For computed or derived values:

```hcl
locals {
  instance_name = "hw-${var.env_prefix}-ec2"
}
```

---

### 6. ❌ Avoid `aws_default_*` Resources for Production

You’re using:

```hcl
resource "aws_default_route_table" "main_route_table" { ... }
resource "aws_default_security_group" "default_sg" { ... }
```

⚠️ These mutate the default AWS setup, which may cause **cross-environment issues**.

➖ Instead, use:

```hcl
resource "aws_security_group" "web_sg" { ... }
resource "aws_route_table" "custom_route_table" { ... }
```

---

### 7. ✅ Output Resources with Labels

Instead of outputting just values, add clarity:

```ini
output "server_public_ip" {
  description = "The public IP of the web server"
  value       = module.hw_web_server_module.server_public_ip
}
```

---

## 🧠 Summary: Variable Repetition

| Question                             | Answer                                                            |
| ------------------------------------ | ----------------------------------------------------------------- |
| Do we need variables in each module? | ✅ Yes. Modules are isolated and need their own interface.        |
| Can we reuse variables smartly?      | ✅ Use consistent names, root-level defaults, or wrapper modules. |
| Is DRY possible?                     | ✅ Partially, but Terraform forces explicitness for clarity.      |
