# 🐚 Running Shell Scripts in GitHub Actions

## 🧭 Overview

GitHub Actions allows you to run shell scripts as part of your CI/CD workflows. You can:

- Run shell commands **inline**
- Execute external `.sh` scripts stored in your repo
- Pass **arguments** and **environment variables**
- Use **`chmod +x`** to ensure scripts are executable

This guide covers all of that with examples and best practices.

---

## ✅ Option 1: Run Shell Commands Inline

```yaml
steps:
  - name: Run inline shell commands
    run: |
      echo "Step 1: Installing"
      npm install
      echo "Step 2: Testing"
      npm test
```

This runs directly in the runner’s shell (default is **bash** on Linux).

---

## ✅ Option 2: Run an External `.sh` Script

Assuming your repo has:

```ini
project-a/
├── build.sh
```

### 🧪 Basic Workflow

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Run external script
        run: ./project-a/build.sh
```

---

## 🔐 Why You Might Need `chmod +x`

If the script **isn’t executable**, running `./build.sh` will fail with:

```ini
permission denied: ./build.sh
```

This often happens if:

- The script was created on Windows
- It was committed without executable permissions

### ✅ Fix it in the workflow:

```yaml
steps:
  - uses: actions/checkout@v3
  - name: Make script executable and run
    run: |
      chmod +x ./project-a/build.sh
      ./project-a/build.sh
```

### ✅ Or fix it before committing:

```bash
chmod +x project-a/build.sh
git add project-a/build.sh
git commit -m "Make script executable"
```

---

## 🧪 Example with Arguments and Environment Variables

```yaml
steps:
  - uses: actions/checkout@v3
  - name: Run script with args
    run: ./deploy.sh staging v1.2.3
  - name: Run script with env
    run: ./deploy.sh
    env:
      ENVIRONMENT: staging
      VERSION: v1.2.3
```

Inside `deploy.sh`:

```bash
echo "Deploying to $ENVIRONMENT version $VERSION"
```

---

## 🧠 Shell Behavior and Tips

| Feature         | Behavior                                       |
| --------------- | ---------------------------------------------- |
| Default shell   | `bash` on Linux/macOS, `PowerShell` on Windows |
| Change shell    | `shell: bash` or `shell: pwsh`                 |
| Source env vars | `source ./env.sh` or `. ./env.sh`              |
| Run in subdir   | Use `working-directory:` or `cd` in `run:`     |

---

## 🧠 Summary

| Use Case        | Example                             |
| --------------- | ----------------------------------- |
| Inline shell    | `run: echo "Hello"`                 |
| External script | `run: ./build.sh`                   |
| With `chmod +x` | `chmod +x ./build.sh && ./build.sh` |
| With args       | `run: ./deploy.sh staging`          |
| With env vars   | `env: { ENV: prod }`                |
