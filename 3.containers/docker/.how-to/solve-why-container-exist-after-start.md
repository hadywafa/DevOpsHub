# 🐳 Why Docker Container Exits Immediately After start

## 🧠 What’s Happening

### 🔍 Your Commands:

```bash
docker container start --name my_ubuntu ubuntu
docker container exec -it my_ubuntu /bin/bash
```

### ❌ Error:

> `Error response from daemon: container ... is not running`

This means the container **started**, but its main process **exited instantly**, so it’s no longer running by the time you tried to `exec`.

---

## 🔍 Why It Happens

- The container was originally created with a **short-lived command** (like `echo`, or no command at all).
- When you start it, Docker runs that command again — it finishes quickly, and the container exits.

---

## ✅ How to Fix It

### Step 1: Remove the Container

```bash
docker container rm my_ubuntu
```

### Step 2: Recreate with a Shell

Start a new container with a long-lived process like `bash`:

```bash
docker run -it --name my_ubuntu ubuntu /bin/bash
```

This keeps the container alive and interactive.

---

### Option: Inspect the Original Command

Check what command the container was created with:

```bash
docker inspect laughing_dirac --format='{{.Config.Cmd}}'
```

If it shows something like `[""]` or `["echo", "hello"]`, that’s why it exits.

---

### 🧩 Summary Table

| Action                       | Result                               |
| ---------------------------- | ------------------------------------ |
| `docker start`               | Runs original command, may exit fast |
| `docker exec` after exit     | ❌ Fails — container not running     |
| `docker run -it ubuntu bash` | ✅ Starts fresh, stays interactive   |
| `docker inspect`             | ✅ Reveals original command          |
