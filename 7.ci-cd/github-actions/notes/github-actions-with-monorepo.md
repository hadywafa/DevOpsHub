# 🧭 **Configuring GitHub Actions for Monorepos**

## 📖 Overview

In large monorepos containing multiple isolated projects, configuring GitHub Actions to trigger CI/CD workflows per project requires careful setup. GitHub Actions **only detects workflows in the root `.github/workflows/` directory**, so placing workflow files inside each project’s subfolder will not trigger them.

This guide explains:

- Why workflows in subfolders don’t run
- How to structure your monorepo for CI/CD
- How to scope workflows to individual projects
- Optional enhancements like matrix builds and caching

---

## ⁉️ Why Your Workflows in Subfolders (Monorepo) Aren’t Triggering

GitHub Actions only looks for workflows in **one place**:

```ini
<repo-root>/.github/workflows/
```

So if each project has its own isolated folder like:

```ini
project-a/.github/workflows/
project-b/.github/workflows/
```

GitHub **won’t detect or run those workflows**. They must be moved or symlinked to the root `.github/workflows/` directory.

---

## ✅ Recommended Directory Structure

```bash
repo-root/
├── project-a/
│   └── code, Dockerfile, etc.
├── project-b/
│   └── code, Dockerfile, etc.
└── .github/
    └── workflows/
        ├── project-a-ci.yml
        ├── project-b-ci.yml
```

> ✅ All workflow files must reside in `.github/workflows/` at the repo root.

---

## ⚡ Triggering Workflows Per Project

Use the `paths:` filter in the `on:` section to scope each workflow to its corresponding project.

### 🧪 Example: `project-a-ci.yml`

```yaml
name: CI for Project A

on:
  push:
    paths:
      - "project-a/**"
  pull_request:
    paths:
      - "project-a/**"

jobs:
  build:
    runs-on: ubuntu-latest
    defaults:
      run:
        working-directory: project-a
    steps:
      - uses: actions/checkout@v3
      - run: echo "Running CI for Project A"
      - run: ./build.sh
```

### 🧪 Example: `project-b-ci.yml`

```yaml
name: CI for Project B

on:
  push:
    paths:
      - "project-b/**"
  pull_request:
    paths:
      - "project-b/**"

jobs:
  test:
    runs-on: ubuntu-latest
    defaults:
      run:
        working-directory: project-b
    steps:
      - uses: actions/checkout@v3
      - run: echo "Running tests for Project B"
      - run: ./test.sh
```

---

## 🧩 Optional Enhancements

### 🔁 Matrix Builds (Shared Logic Across Projects)

```yaml
name: CI Matrix

on:
  push:
    paths:
      - "project-a/**"
      - "project-b/**"

jobs:
  build:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        project: [project-a, project-b]
    defaults:
      run:
        working-directory: ${{ matrix.project }}
    steps:
      - uses: actions/checkout@v3
      - run: ./ci.sh
```

### 🚀 Triggering CD Only from `main`

```yaml
on:
  push:
    branches:
      - main
    paths:
      - "project-a/**"

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - run: ./deploy.sh
```

---

## 🛡️ Enforcing CI with Branch Protection

To ensure workflows run and pass before merging:

- Go to **Settings → Branches → Branch Protection Rules**
- Add required status checks:
  - `CI for Project A`
  - `CI for Project B`

This ensures that PRs cannot be merged unless their scoped CI passes.

---

## 🧠 Summary

| Problem                 | Solution                     |
| ----------------------- | ---------------------------- |
| Workflows in subfolders | Move to `.github/workflows/` |
| CI per project          | Use `paths:` filter          |
| Project isolation       | Use `working-directory:`     |
| Shared logic            | Use matrix builds            |
| Deployment gating       | Trigger CD only from `main`  |
| Merge safety            | Enforce branch protection    |
