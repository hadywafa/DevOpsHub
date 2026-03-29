# 🗝️ Container Privilege

## 🔑 What `--privileged` Does

When you run a container with `--privileged`, Docker gives it **almost the same level of access as the host system**. Specifically:

- **All Linux capabilities**:
  - Normally, containers run with a reduced set of capabilities (like `CAP_NET_BIND_SERVICE` but not `CAP_SYS_ADMIN`).
  - `--privileged` grants _every_ capability, including powerful ones like mounting filesystems, configuring devices, and changing kernel parameters.
- **Device access**: The container can access all devices on the host (`/dev/*`), not just a restricted subset.
- **AppArmor/SELinux profiles**: Security restrictions are lifted or relaxed, so the container isn’t confined by those policies.
- **cgroup modifications**: The container can manipulate cgroups and potentially affect other containers.
- **Kernel features**: Things like loading kernel modules, using `mknod`, or running low-level debugging tools become possible.

---

## ⚠️ Why It’s Risky

- A privileged container can **escape isolation** and compromise the host.
- It’s essentially like running processes directly on the host with root privileges.
- Best practice: avoid `--privileged` unless absolutely necessary (e.g., running system-level tools like `Tracee`, `sysdig`, or Docker-in-Docker).

---

## ✅ Safer Alternatives

Instead of `--privileged`, you can grant **specific capabilities** with `--cap-add`:

```bash
docker run --rm -it \
  --cap-add=SYS_ADMIN \
  --cap-add=NET_ADMIN \
  ubuntu bash
```

This way, you only give the container the powers it needs, not full host-level access.

---

## 🧩 Example

- Running `docker run --privileged ubuntu bash` → the container can mount filesystems, access `/dev/kmsg`, and load kernel modules.
- Running `docker run ubuntu bash` (without privileged) → the container is sandboxed, can’t touch host devices, and has limited capabilities.
