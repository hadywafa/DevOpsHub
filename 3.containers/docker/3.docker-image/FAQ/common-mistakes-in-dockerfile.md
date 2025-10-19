# 🐳 Docker ENTRYPOINT vs CMD — Wrong ❌ vs Correct ✅ Scenarios

## ⚠️ Scenario 1: Missing ENTRYPOINT Command

### ❌ Wrong

```dockerfile
FROM python:3.12-slim
WORKDIR /app
COPY app.py .
CMD ["--port", "8080"]    # No command, only arguments
```

### Result

```ini
exec: "--port": executable file not found in $PATH
```

### ✅ Correct

```dockerfile
FROM python:3.12-slim
WORKDIR /app
COPY app.py .
ENTRYPOINT ["python", "app.py"]
CMD ["--port", "8080"]
```

### Output

```ini
START ['app.py', '--port', '8080']
```

---

## ⚠️ Scenario 2: Shell Form ENTRYPOINT (bad signal handling)

### ❌ Wrong

```dockerfile
ENTRYPOINT python app.py
```

➡ Runs via `/bin/sh -c` → Python becomes **child process**, not PID 1.

### Problem

- Container doesn’t stop immediately with `docker stop`
- Signals (SIGTERM) are lost

### ✅ Correct

```dockerfile
ENTRYPOINT ["python", "app.py"]
```

➡ Python runs directly as PID 1 → proper signal handling and clean shutdown.

---

## ⚠️ Scenario 3: CMD Overridden by ENTRYPOINT

### ❌ Wrong

```dockerfile
ENTRYPOINT ["echo", "Starting..."]
CMD ["python", "app.py"]
```

### Output

```ini
Starting... python app.py
```

→ App never runs; container exits instantly.

### ✅ Correct

```dockerfile
ENTRYPOINT ["python", "app.py"]
CMD ["--debug"]
```

### Output

```ini
Running app.py --debug
```

---

## ⚠️ Scenario 4: Shell Script ENTRYPOINT Without `exec "$@"`

### ❌ Wrong

```bash
# docker-entrypoint.sh
#!/bin/sh
python setup.py install
"$@"
```

➡ App runs as **child process** of the shell → signals ignored.

### ✅ Correct

```bash
#!/bin/sh
python setup.py install
exec "$@"
```

➡ `exec` replaces shell with your app → proper PID 1 and clean stop.

---

## ⚠️ Scenario 5: Trying to Override ENTRYPOINT (Doesn’t Work as Expected)

### ❌ Wrong Assumption

```dockerfile
ENTRYPOINT ["python", "app.py"]
CMD ["--port", "8080"]
```

```bash
docker run myapp ls     # ❌ You think it runs `ls`
```

➡ Actually runs: `python app.py ls` 😬

### ✅ Correct Override

```bash
docker run --entrypoint ls myapp
```

✅ Works → runs `ls` inside the container.

---

## ✅ Quick Summary

| Goal                | Wrong ❌                      | Correct ✅                         |
| ------------------- | ----------------------------- | ---------------------------------- |
| Define default args | Only `CMD` → “exec not found” | Use `ENTRYPOINT` + `CMD`           |
| Run as PID 1        | `ENTRYPOINT python app.py`    | `ENTRYPOINT ["python","app.py"]`   |
| Allow arguments     | Hard-coded shell commands     | Use `CMD` for default args         |
| Use entry script    | Missing `exec "$@"`           | Always `exec "$@"` at end          |
| Override behavior   | `docker run myapp ls` fails   | `docker run --entrypoint ls myapp` |

---

### 💡 Golden Rule

> 🧠 **ENTRYPOINT = what to run**
> 🧠 **CMD = with what arguments**

Always prefer the **JSON (exec) form** for clean, predictable container behavior.
