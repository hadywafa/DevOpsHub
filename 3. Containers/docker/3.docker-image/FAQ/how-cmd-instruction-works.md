# 🧑🏻‍💻 **CMD Instruction in details**

## 📖 What the official docs say

- **Source path: trailing `/` is ignored.**

  - `COPY something/ /dest` **≡** `COPY something /dest`.
  - > If **source is a directory**, Docker **copies its contents**, not the directory itself.

- **Destination path: trailing `/` matters.**

  - `COPY file.txt /abs` creates `/abs` **as a file**;
  - `COPY file.txt /abs/` creates `/abs/file.txt`.
  - > If you copy **multiple sources**, destination **must be a directory and end with `/`**.

- **Build context rules** (you can’t copy from `..`): sources are resolved **relative to the build context**.

---

## ✍🏻 Examples

```bash
docker build -t copy-test1 -f Dockerfile-1 .
docker build -t copy-test2 -f Dockerfile-2 .
docker build -t copy-test3 -f Dockerfile-3 .
docker build -t copy-test4 -f Dockerfile-4 .
docker build -t copy-test5 -f Dockerfile-5 .
```

```bash
docker run --rm copy-test1
docker run --rm copy-test2
docker run --rm copy-test3
docker run --rm copy-test4
docker run --rm copy-test5
```

### 🧩 Example 1 — Copy folder contents

```dockerfile
# Dockerfile-1
FROM alpine
RUN apk update && apk add tree
WORKDIR /app
COPY src /app/
CMD ["tree", "/app"]
```

**Expected output:**

```ini
/app
├── file1.txt
├── file2.txt
└── subdir
    └── nested.txt
```

---

### 🧩 Example 2 — Copy contents into a named subdir

```dockerfile
# Dockerfile-2
FROM alpine
RUN apk update && apk add tree
WORKDIR /app
COPY src /app/src/
CMD ["tree", "/app"]
```

**Expected output:**

```ini
/app
└── src
    ├── file1.txt
    ├── file2.txt
    └── subdir
        └── nested.txt
```

---

### 🧩 Example 3 — Copy and rename file

```dockerfile
# Dockerfile-3
FROM alpine
RUN apk update && apk add tree
WORKDIR /app
COPY src/file1.txt /app/renamed
CMD ["tree", "/app"]
```

**Expected output:**

```ini
/app
└── renamed
```

---

### 🧩 Example 4 — Multiple sources

```dockerfile
# Dockerfile-4
FROM alpine
RUN apk update && apk add tree
WORKDIR /app
COPY src/file1.txt src/file2.txt /app/files/
CMD ["tree", "/app"]
```

**Expected output:**

```ini
/app
└── files
    ├── file1.txt
    └── file2.txt
```

---

### 🧩 Example 5 — Everything (use `.dockerignore`)

```dockerfile
# Dockerfile-5
FROM alpine
RUN apk update && apk add tree
WORKDIR /app
COPY . /app/
CMD ["tree", "-L", "2", "/app"]
```

✅ Create `.dockerignore` to skip noise:

```ini
.git
node_modules
*.log
```

---

## 🧠 **TL;DR**

- **Source dir** → copies **contents** (trailing `/` on source is **ignored**).
- **Destination** decides file vs directory; trailing `/` **matters**.
- **Multiple sources** → dest must be a dir with `/`.
- All sources must be **inside build context**.
