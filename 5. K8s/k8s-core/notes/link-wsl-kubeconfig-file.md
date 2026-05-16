# 🔗 **Link WSL kubeconfig file from Windows to WSL Ubuntu**

To link your **Windows kubeconfig file** (`C:\Users\Hady\.kube\config`) into **WSL Ubuntu** (`~/.kube/config`) so that **Windows remains the single source of truth**, follow this detailed guide:

---

## 🎯 Goal

Ensure that:

- You **edit only the Windows file**.
- WSL Ubuntu always uses the Windows version via a **symbolic link**.
- Changes made in Windows (e.g., via VS Code or PowerShell) are instantly reflected in WSL.

---

Great question, Hady — let’s clarify what **“WSL → Windows” direction** means in the context of linking your kubeconfig file.

---

## 🔁 Direction: WSL → Windows

This means that your **WSL Ubuntu environment is reading from a file that physically lives in Windows**.

### 🔗 You create a symbolic link inside WSL like this:

```bash
ln -sf /mnt/c/Users/Hady/.kube/config ~/.kube/config
```

### ✅ What this does:

- Inside WSL, your `~/.kube/config` is **not a real file** — it’s just a **pointer (symlink)** to the Windows file at `/mnt/c/Users/Hady/.kube/config`.
- Any tool running in WSL (like `kubectl`, `helm`, etc.) will read the Windows file transparently.
- You can edit the file in Windows (e.g., with VS Code, PowerShell, or Notepad), and WSL will instantly see the changes.

---

## 🚫 Why the reverse (Windows → WSL) doesn’t work

Windows **cannot** create a symlink or shortcut that points into WSL’s Linux filesystem (`\\wsl$\Ubuntu\home\hady\.kube\config`) in a way that works reliably across tools. Some apps might read it, but many won’t — especially CLI tools like `kubectl.exe`.

---

## 🧰 Prerequisites

- You have WSL installed (Ubuntu).
- You have a valid kubeconfig file at `C:\Users\Hady\.kube\config`.
- You can access `/mnt/c/Users/Hady/.kube/config` from WSL.

---

## 🪄 Step-by-Step Setup

### ✅ Step 1: Locate Windows kubeconfig

In PowerShell or CMD:

```powershell
echo $env:USERPROFILE\.kube\config
```

This should return:

```ini
C:\Users\Hady\.kube\config
```

### ✅ Step 2: Remove any existing WSL kubeconfig

In WSL Ubuntu:

```bash
rm -f ~/.kube/config
```

> This ensures there's no conflict with an existing file.

### ✅ Step 3: Create a symbolic link from WSL to Windows

In WSL Ubuntu:

```bash
ln -sf /mnt/c/Users/Hady/.kube/config ~/.kube/config
```

> This links your WSL `~/.kube/config` to the Windows file. The `-s` creates a symbolic link, and `-f` forces overwrite if needed.

### ✅ Step 4: Test the link

In WSL:

```bash
kubectl config get-contexts
```

If it works, you're done! 🎉

---

## 🔁 Optional: Auto-refresh on shell startup

To ensure the link is always refreshed (especially if the file is deleted or recreated), add this to your WSL shell config:

### For Bash:

```bash
echo 'ln -sf /mnt/c/Users/Hady/.kube/config ~/.kube/config' >> ~/.bashrc
```

### For Zsh:

```bash
echo 'ln -sf /mnt/c/Users/Hady/.kube/config ~/.kube/config' >> ~/.zshrc
```

Then reload:

```bash
source ~/.bashrc  # or ~/.zshrc
```

---

## 🧪 Verify One-Way Edit Behavior

Try editing the Windows file in VS Code or PowerShell:

```powershell
notepad $env:USERPROFILE\.kube\config
```

Then in WSL:

```bash
kubectl config view
```

You should see the updated config immediately.

---

Would you like to also link Helm config (`~/.config/helm`) or expose Kind clusters from Windows to WSL? I can help unify your dev tooling across both environments.
