# Notes

![1753469745926](image/notes/1753469745926.png)

![1753469981226](image/notes/1753469981226.png)

![1753470600394](image/notes/1753470600394.png)

![1753470941301](image/notes/1753470941301.png)

![1753472771232](image/notes/1753472771232.png)

![1753474945231](image/notes/1753474945231.png)

![1753475192393](image/notes/1753475192393.png)

![1753478002757](image/notes/1753478002757.png)

![1753478386707](image/notes/1753478386707.png)

```ini
module "my_module" {
  source    = "./my_module"
  providers = {
    aws = aws.us_east_1
  }
}
```

![1753478862140](image/notes/1753478862140.png)

![1753478957411](image/notes/1753478957411.png)

![1753484276296](image/notes/1753484276296.png)

![1753518766933](image/notes/1753518766933.png)

![1753518844543](image/notes/1753518844543.png)

![1753523135825](image/notes/1753523135825.png)

![1753523295366](image/notes/1753523295366.png)

![1753523578250](image/notes/1753523578250.png)

![1753525727853](image/notes/1753525727853.png)

![1753527969735](image/notes/1753527969735.png)

![1753528158417](image/notes/1753528158417.png)

![1753528439132](image/notes/1753528439132.png)

![1753528499979](image/notes/1753528499979.png)

> You can set TF_LOG to one of the log levels (in order of decreasing verbosity) TRACE, DEBUG, INFO, WARN or ERROR to change the verbosity of the logs. Also if we set TF_LOG to JSON, it output logs at the TRACE level or higher, and uses a parseable JSON encoding as the formatting.

![1753528545233](image/notes/1753528545233.png)

![1753532272813](image/notes/1753532272813.png)

![1753532832908](image/notes/1753532832908.png)

![1753533059343](image/notes/1753533059343.png)

![1753537267008](image/notes/1753537267008.png)

![1753538550333](image/notes/1753538550333.png)

## Q200

![1753538593217](image/notes/1753538593217.png)

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

## Q201

![1753538907990](image/notes/1753538907990.png)

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

## Q202

![1753542464383](image/notes/1753542464383.png)

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

## Q203

![1753542695831](image/notes/1753542695831.png)

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
