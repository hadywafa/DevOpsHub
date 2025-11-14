# kubectl autocompletion

## 🛠️ Step-by-Step: Enable `kubectl` Autocompletion in Zsh

### ✅ 1. Install the completion script

Run this in your terminal:

```bash
kubectl completion zsh > ~/.kubectl_completion
```

This generates the autocompletion script and saves it to your home directory.

---

### ✅ 2. Source it in your `.zshrc`

Edit your `.zshrc` file:

```bash
nano ~/.zshrc
```

Add the following lines at the end:

```bash
# Enable kubectl autocompletion
source ~/.kubectl_completion

# Optional: alias 'k' to 'kubectl' with autocompletion
alias k='kubectl'
compdef k=kubectl
```

---

### ✅ 3. Apply changes

Reload your shell:

```bash
source ~/.zshrc
```

Now you can use:

```bash
k get <TAB>
kubectl get <TAB>
```

…to autocomplete resource types, namespaces, pod names, etc.

---

### 🧠 Bonus: Use Oh My Zsh Kubernetes Plugin

If you're using [Oh My Zsh](https://ohmyz.sh/), you can enable the built-in Kubernetes plugin:

1. Edit `.zshrc`:

   ```bash
   plugins=(git kubectl)
   ```

2. Reload:

   ```bash
   source ~/.zshrc
   ```
