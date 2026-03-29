# Notes

## 📌 Q01

![1753469745926](1753469745926.png)

---

## 📌 Q01

![1753469981226](1753469981226.png)

---

## 📌 Q01

![1753470600394](1753470600394.png)

---

## 📌 Q01

![1753470941301](1753470941301.png)

---

## 📌 Q01

![1753472771232](1753472771232.png)

---

## 📌 Q01

![1753474945231](1753474945231.png)

---

## 📌 Q01

![1753475192393](1753475192393.png)

---

## 📌 Q01

![1753478002757](1753478002757.png)

---

## 📌 Q01

![1753478386707](1753478386707.png)

```ini
module "my_module" {
  source    = "./my_module"
  providers = {
    aws = aws.us_east_1
  }
}
```

---

## 📌 Q01

![1753478862140](1753478862140.png)

---

## 📌 Q01

![1753478957411](1753478957411.png)

---

## 📌 Q01

![1753484276296](1753484276296.png)

---

## 📌 Q01

![1753518766933](1753518766933.png)

---

## 📌 Q01

![1753518844543](1753518844543.png)

---

## 📌 Q01

![1753523135825](1753523135825.png)

---

## 📌 Q01

![1753523295366](1753523295366.png)

---

## 📌 Q01

![1753523578250](1753523578250.png)

---

## 📌 Q01

![1753525727853](1753525727853.png)

---

## 📌 Q01

![1753527969735](1753527969735.png)

---

## 📌 Q01

![1753528158417](1753528158417.png)

---

## 📌 Q01

![1753528439132](1753528439132.png)

---

## 📌 Q01

![1753528499979](1753528499979.png)

> You can set TF_LOG to one of the log levels (in order of decreasing verbosity) TRACE, DEBUG, INFO, WARN or ERROR to change the verbosity of the logs. Also if we set TF_LOG to JSON, it output logs at the TRACE level or higher, and uses a parseable JSON encoding as the formatting.

---

## 📌 Q01

![1753528545233](1753528545233.png)

---

## 📌 Q01

![1753532272813](1753532272813.png)

---

## 📌 Q01

![1753532832908](1753532832908.png)

---

## 📌 Q01

![1753533059343](1753533059343.png)

---

## 📌 Q01

![1753537267008](1753537267008.png)

---

## 📌 Q01

![1753538550333](1753538550333.png)

---

## 📌 Q200

![1753538593217](1753538593217.png)

---

### ✅ Correct answer: `True`

---

### 💡 Explanation

Terraform's `file()` and `templatefile()` functions **read static files from disk** at the time **Terraform is initialized and planning**.
They **cannot read files generated dynamically during the same run**, because:

- Terraform evaluates functions **before** creating resources.
- Any dynamic files created _during_ `plan` or `apply` won't exist yet.

---

#### 🧨 Example (What NOT to do):

```ini
resource "null_resource" "generate_file" {
  provisioner "local-exec" {
    command = "echo 'data' > dynamic.txt"
  }
}

output "file_content" {
  value = file("dynamic.txt")  # ❌ Fails: file doesn't exist yet during planning
}
```

---

#### ✅ Best Practice:

Generate dynamic files **outside** Terraform (e.g. in a script **before** `terraform apply`) if you want to use `file()` or `templatefile()` on them.

---

## 📌 Q201

![1753538907990](1753538907990.png)

---

### ❌ Why the selected answer is wrong

**Selected answer:** `Terraform doesn’t support expanding arguments this way`
This is incorrect because **Terraform _does_ support argument expansion** using the `...` (splat) operator.

---

### ✅ Correct answer

**Correct answer:** `Provide the list value as an argument and follow it with the “...” symbol`

---

### 💡 Explanation with Example

Terraform allows **argument expansion** using the triple-dot syntax (`...`) when a function expects multiple values, but you have a list.

#### ✅ Example:

```ini
locals {
  items = [1, 2, 3]
}

output "max_value" {
  value = max(local.items...)  # same as max(1, 2, 3)
}
```

Without `...`, you'd pass a **list** (`[1,2,3]`) instead of **multiple arguments**, which would cause an error if the function expects unpacked values.

---

## 📌 Q202

![1753542464383](1753542464383.png)

---

### ❌ Why `dynamic` is wrong

You selected `dynamic` as the answer, but that’s incorrect because **`dynamic` is a feature**, not a block type.
It’s used _to generate_ other nested blocks dynamically — not something we check for compatibility.

---

### ✅ Correct answer: `locals`

---

### 💡 Explanation

Dynamic blocks can only be used **inside**:

- `resource`
- `data`
- `provider`
- `provisioner`

But **`locals` does not support `dynamic`**, because local values must be static and known during Terraform’s evaluation phase.

---

#### ✅ Valid Example:

```ini
resource "aws_security_group" "example" {
  dynamic "ingress" {
    for_each = var.rules
    content {
      from_port = ingress.value.from
      to_port   = ingress.value.to
      protocol  = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }
}
```

---

#### ❌ Invalid Example:

```ini
locals {
  dynamic "something" { ... }  # ❌ Invalid: dynamic blocks can't be used in locals
}
```

---

## 📌 Q203

![1753542695831](1753542695831.png)

---

### ✅ Correct answer: `Yes`

---

### 💡 Explanation

Terraform **does allow nesting a `dynamic` block inside another `dynamic` block**, especially when you're generating complex nested structures like `ingress → ports`, `rules → conditions`, etc.

---

#### ✅ Example: Nested `dynamic` blocks

```ini
resource "aws_security_group" "example" {
  name = "example"

  dynamic "ingress" {
    for_each = var.ingress_rules
    content {
      from_port = ingress.value.from_port
      to_port   = ingress.value.to_port
      protocol  = ingress.value.protocol

      dynamic "cidr_blocks" {
        for_each = ingress.value.cidr_blocks
        content {
          cidr_blocks = [cidr_blocks.value]
        }
      }
    }
  }
}
```

- Outer `dynamic "ingress"` generates `ingress` blocks.
- Inner `dynamic "cidr_blocks"` generates sub-blocks within each `ingress`.

---

✅ Totally allowed. Just remember:

- You must carefully manage variable scoping (`ingress.value`, `cidr_blocks.value`).
- Deep nesting should be used only when really needed for readability.

---

## 📌 Q204

![1753544064239](1753544064239.png)

---

### ✅ Correct answer: `module composition`

---

### 💡 Explanation

The example shows **multiple modules used side by side**, like building blocks, each doing one job — this is called **flat module composition**.

```ini
module "network" {
  source = "./modules/aws-network"
  ...
}

module "consul_cluster" {
  source = "./modules/aws-consul-cluster"
  ...
}
```

This approach is:

- 🧱 Flat — no module nesting
- ⚙️ Composed — each module does a specific task
- 🔄 Reusable — modules can be combined in various ways

---

### ❌ Why others are wrong

- `dependency inversion` → Not a Terraform term (comes from software architecture)
- `module gathering` → Not a real Terraform concept
- `None of the above` → Incorrect because “module composition” is valid

---

## 📌 Q205

![1753544183168](1753544183168.png)

---

### ✅ Correct answer: `root`

---

### 💡 Explanation

The **root module** is the **entry point** of your Terraform configuration — usually your main `.tf` files in the top directory.

It can:

- Call **child modules**
- Pass **input variables** to them
- Capture **outputs** from one module and pass to another

---

### 🔗 Example: Connecting modules in the root module

```ini
# main.tf (Root module)
module "network" {
  source     = "./modules/network"
  cidr_block = "10.0.0.0/16"
}

module "app_server" {
  source     = "./modules/app"
  subnet_id  = module.network.subnet_id  # 👈 output from network module
}
```

#### Inside `modules/network/outputs.tf`:

```ini
output "subnet_id" {
  value = aws_subnet.main.id
}
```

✔️ The root module glues everything together.

---

### ❌ Why others are wrong

- `default` → No such module type in Terraform
- `child` → Child modules **cannot** call other modules
- `provider` → Providers configure infrastructure, not module orchestration

---

## 📌 Q206

![1753544301057](1753544301057.png)

---

### ❌ Why `Both` is wrong

You selected `Both`, but **only one option is correct**. The first one (`/root/ is the root module`) is incorrect — **Terraform doesn’t require or care about any directory named `/root/`**.

---

### ✅ Correct answer:

`The current terraform configuration directory consisting of .tf files forms the root module.`

---

### 💡 Explanation

In Terraform:

- The **root module** = the **directory where you run `terraform init/plan/apply`**
- It includes all `.tf` and `.tf.json` files in that directory.

✅ Example:

```bash
📁 /project/
├── main.tf
├── variables.tf
├── outputs.tf
└── modules/
     └── vpc/
         └── main.tf
```

If you run Terraform inside `/project`, it’s your **root module**, and `modules/vpc` is a **child module**.

---

### 🛑 `/root/` confusion

`/root/` is just a Linux path — it has **nothing to do with Terraform modules**. Terraform never expects that name.

---

## 📌 Q207

![1753544361694](1753544361694.png)

---

### ❌ Why `terraform module pull` is wrong

You selected `terraform module pull`, but that command **does not exist** in Terraform CLI.
There's **no such command** — it’s made up. Terraform will throw an error if you try it.

---

### ✅ Correct answers:

- `terraform init` ✅
- `terraform get` ✅

---

### 💡 Explanation

Terraform downloads modules in two main ways:

#### ✅ `terraform init`

- Downloads **providers and modules**
- Automatically fetches modules from `source =` blocks

#### ✅ `terraform get`

- Explicitly downloads modules (usually used in automation/scripts)
- Only useful if you're **not using `init` yet**

---

### ❌ Invalid choices

- `terraform module pull` → ❌ Not a real command
- `terraform pull` → ❌ Used for [Terraform Cloud state pull](https://developer.hashicorp.com/terraform/cli/commands/pull), not for modules

---

## 📌 Q208

![1753548141840](1753548141840.png)

---

## 📌 Q209

![1753548476940](1753548476940.png)

---

## 📌 Q210

![1753548638889](1753548638889.png)

---

## 📌 Q211

![1753552643442](1753552643442.png)

---

## 📌 Q212

![1753552908910](1753552908910.png)
