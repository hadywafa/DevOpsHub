# 🤹🏻‍♂️ **Multiple Commands in One Step**

To run multiple commands in a **single step** in GitHub Actions, you simply use a multiline `run:` block with a pipe `|`.  
Here's how it works:

---

```yaml
steps:
  - name: Run multiple commands
    run: |
      echo "Step 1: Installing dependencies"
      npm install

      echo "Step 2: Running tests"
      npm test

      echo "Step 3: Building project"
      npm run build
```

## 🔍 Explanation:

- The `run:` key accepts a **multiline string** using the pipe `|` symbol.
- Each line is executed sequentially in the same shell session.
- You can use shell features like `&&`, `||`, `if`, `cd`, etc.

---

## 🧪 Example with Bash Logic

```yaml
steps:
  - name: Conditional build
    run: |
      echo "Checking environment..."
      if [ "$CI_ENV" = "production" ]; then
        echo "Running production build"
        npm run build:prod
      else
        echo "Running dev build"
        npm run build:dev
      fi
```

---

## 🧩 Example with Directory Change

```yaml
steps:
  - name: Build project-a
    run: |
      cd project-a
      npm install
      npm test
```

---

## 🛠️ Tips

- You can also use `&&` to chain commands:

  ```yaml
  run: npm install && npm test && npm run build
  ```

- For complex logic, prefer multiline `run:` blocks for readability.
- If you need environment variables, use `env:`:

  ```yaml
  env:
    NODE_ENV: production
  ```
