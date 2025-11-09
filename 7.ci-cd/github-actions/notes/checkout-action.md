# 🧩 What Is `actions/checkout`?

The `actions/checkout` action is a **core GitHub Action** that **clones your repository** into the runner’s workspace so subsequent steps can access your code.

Without it, your workflow has **no access to your repo files** — no source code, no Dockerfiles, no scripts.

---

## ⚙️ How It Works

```yaml
- uses: actions/checkout@v3
```

This:

- Authenticates with GitHub
- Clones the repo into the runner’s working directory
- Makes the code available for build, test, lint, deploy, etc.

---

## 🧪 Common Use Cases

### 1. ✅ Build and Test Your Code

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - run: npm install
      - run: npm test
```

Without `checkout`, `npm install` would fail because `package.json` wouldn’t exist.

---

### 2. 🧩 Multi-Project Monorepo

```yaml
jobs:
  project-a:
    runs-on: ubuntu-latest
    defaults:
      run:
        working-directory: project-a
    steps:
      - uses: actions/checkout@v3
      - run: ./build.sh
```

This ensures `project-a/` is available for build/test.

---

### 3. 📦 Access Dockerfile or Deployment Scripts

```yaml
steps:
  - uses: actions/checkout@v3
  - run: docker build -t my-app .
```

The Dockerfile must be present — `checkout` makes it available.

---

### 4. 🔁 Use with Matrix Builds

```yaml
strategy:
  matrix:
    project: [project-a, project-b]

steps:
  - uses: actions/checkout@v3
  - run: ./ci.sh
    working-directory: ${{ matrix.project }}
```

Each matrix job gets its own fresh clone of the repo.

---

### 5. 🔐 Use with Private Submodules

```yaml
- uses: actions/checkout@v3
  with:
    submodules: true
    token: ${{ secrets.GITHUB_TOKEN }}
```

This clones submodules using the GitHub token for authentication.

---

## 🔧 Advanced Options

| Option        | Description                                        |
| ------------- | -------------------------------------------------- |
| `ref`         | Checkout a specific branch or tag                  |
| `fetch-depth` | Limit history depth (default is `1`)               |
| `submodules`  | Clone submodules (`true`, `recursive`)             |
| `token`       | Use a custom token for private repos or submodules |

**Example:**

```yaml
- uses: actions/checkout@v3
  with:
    ref: main
    fetch-depth: 0 # full history
```

---

## 🧠 Summary

| Feature            | Purpose                                    |
| ------------------ | ------------------------------------------ |
| `actions/checkout` | Clones your repo into the runner           |
| Required for       | Build, test, lint, deploy, Docker, scripts |
| Supports           | Submodules, shallow clones, custom refs    |
| Use in             | Every job that needs repo access           |
