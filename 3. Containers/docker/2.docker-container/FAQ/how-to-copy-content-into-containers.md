# 🎞️ Copying Files _Into_ a Running Container

Copying content into a Docker container is a common task for injecting configuration files, scripts, binaries, or even entire directories. Let’s break it down modularly so you can use it in troubleshooting, documentation, or portfolio-ready workflows.

---

## 📦 1. Copying Files _Into_ a Running Container

### ✅ Syntax

```bash
docker cp <local_path> <container_id>:<container_path>
```

### 🧪 Example

```bash
docker cp ./config.yaml a3b1d58384b9:/app/config.yaml
```

- Copies `config.yaml` from your host into `/app/` inside container `a3b1d58384b9`

---

## 📦 2. Copying _Directories_ Into a Container

```bash
docker cp ./myfolder a3b1d58384b9:/app/myfolder
```

- Recursively copies everything inside `./myfolder` into `/app/myfolder` in the container

---

## 🧠 3. When to Use `docker cp`

| Use Case                       | `docker cp` Good? | Why?                                      |
| ------------------------------ | ----------------- | ----------------------------------------- |
| Injecting config files         | ✅ Yes            | Fast and simple                           |
| Copying scripts for debugging  | ✅ Yes            | No rebuild needed                         |
| Updating static assets         | ✅ Yes            | Avoids full image rebuild                 |
| Copying into stopped container | ✅ Yes            | Works even if container is paused/stopped |
| Copying into volume mount      | ⚠️ Maybe          | Depends on mount visibility               |

---

## 🧩 4. Alternative: COPY in Dockerfile

If you're building an image:

```dockerfile
COPY ./config.yaml /app/config.yaml
```

- Used during `docker build`
- Bakes the file into the image permanently

---

## 🔍 5. Verifying the Copy

Inside the container:

```bash
docker exec -it a3b1d58384b9 ls /app/
```

Or to view file contents:

```bash
docker exec a3b1d58384b9 cat /app/config.yaml
```
