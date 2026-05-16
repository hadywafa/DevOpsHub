# 🧠 How Docker Uses cgroups to Control Containers

Docker leverages **Linux cgroups** to isolate and limit resource usage per container. When you run a container, Docker creates a dedicated cgroup for it and configures resource constraints based on flags like `--memory`, `--cpus`, or `--cpuset-cpus`.

**🔧 Key Resources Docker Can Limit:**

- **CPU**: via `cpu.max` (v2) or `cpu.cfs_quota_us` (v1)
- **Memory**: via `memory.max` (v2) or `memory.limit_in_bytes` (v1)
- **Block I/O**: via `blkio.weight`
- **PIDs**: via `pids.max`

These limits are enforced by the kernel, ensuring containers don’t exceed their assigned quotas.

---

## 🧩 How Docker Applies cgroups Internally

1. **Container Launch**:

   - Docker assigns a unique cgroup path (e.g., `/system.slice/docker-<id>.scope`)
   - It writes resource values into cgroup files before starting the container process

2. **Namespace Isolation**:

   - Docker uses **cgroup namespaces** to isolate container views
   - You can optionally share the host’s cgroup namespace using `--cgroupns=host`

3. **Systemd Integration**:
   - On modern distros (like Ubuntu 24), Docker integrates with systemd slices
   - Containers appear under `/sys/fs/cgroup/system.slice/docker-<id>.scope`

---

## 🔍 How to Check cgroup Limits for a Container

### ✅ 1. Get the Container’s PID

```bash
docker inspect --format '{{.State.Pid}}' <container_id>
```

### ✅ 2. Find the cgroup Path

```bash
cat /proc/<PID>/cgroup
```

Look for a line like:

```ini
0::/system.slice/docker-<id>.scope
```

### ✅ 3. Inspect Limits (cgroup v2)

```bash
cat /sys/fs/cgroup/system.slice/docker-<id>.scope/memory.max
cat /sys/fs/cgroup/system.slice/docker-<id>.scope/cpu.max
```

### ✅ 4. Inspect Usage

```bash
cat /sys/fs/cgroup/system.slice/docker-<id>.scope/memory.current
cat /sys/fs/cgroup/system.slice/docker-<id>.scope/cpu.stat
```

---

## 📌 Bonus: Inspect via Docker CLI

```bash
docker inspect <container_id> --format='{{json .HostConfig}}' | jq
```

Shows:

- `Memory`: memory limit in bytes
- `CpuQuota`, `CpuPeriod`: CPU limits
- `CpusetCpus`: specific cores assigned

---

## 📚 References

- [Docker Docs: Resource Constraints](https://docs.docker.com/engine/containers/resource_constraints/)
- [Earthly Blog: Namespaces and cgroups](https://earthly.dev/blog/namespaces-and-cgroups-docker/)
- [Whexy: Using cgroup v2 inside containers](https://www.whexy.com/posts/cgroup-inside-containers)
