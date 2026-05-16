# Note 1

To make your **Windows kubeconfig (`C:\Users\Hady\.kube\config`) the single source of truth** and automatically sync it into your **WSL Ubuntu (`~/.kube/config`)**, you can use a symbolic link inside WSL.

---

## ✅ One-Time Setup: Link Windows kubeconfig into WSL

### Step 1: Locate your Windows kubeconfig

In PowerShell or CMD:

```powershell
$env:USERPROFILE\.kube\config
# Typically: C:\Users\Hady\.kube\config
```

### Step 2: In WSL Ubuntu, create a symlink

Run this in your WSL terminal:

```bash
ln -sf /mnt/c/Users/Hady/.kube/config ~/.kube/config
```

> This creates a symbolic link so that `~/.kube/config` in WSL always points to the Windows file.

---

## 🧪 Test It

In WSL:

```bash
kubectl config get-contexts
```

If it works, you're synced. Any edits you make in Windows (via VS Code, PowerShell, etc.) will reflect instantly in WSL.

---

## 🛠️ Optional: Automate with `.bashrc` or `.zshrc`

To ensure the link is always refreshed, add this to your WSL shell config:

```bash
# ~/.bashrc or ~/.zshrc
ln -sf /mnt/c/Users/Hady/.kube/config ~/.kube/config
```
