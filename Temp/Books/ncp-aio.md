# NCP-AIO Exam Preparation Plan

**Exam code:** NCP-AIOL
**Register at:** Certiverse (create account first)
**Price:** $500
**Format:** 120 minutes · 30 multiple choice + 3 hands-on labs · Pass/Fail
**Validity:** 2 years
**Book it for:** ~5–6 weeks from today (reschedule is normally allowed up to 24h before)

> This file replaces "Track A" in `Hady_60_Day_Plan_and_Roadmap.md`.
> The original 4-week plan was based on a wrong assumption about what this exam covers.

---

## 1. Read This First — What This Exam Actually Is

The hands-on labs run **inside** the same 120 minutes. When the exam starts, a live cluster is provisioned for you. You need to be fast and comfortable on a Linux command line with **Slurm, Kubernetes, and Base Command Manager**.

### Official blueprint

| Domain | % | Main content |
|---|---|---|
| Installation and Deployment | **31%** | Base Command Manager (BCM), Mission Control, Base View, node categories, image sync, firmware, users/roles, network config for nodes/DPUs/switches, install K8s via BCM, install Slurm, install Run:ai, DOCA on DPU Arm |
| Administration | 23% | Slurm administration, Run:ai administration, Kubernetes administration, **MIG configuration**, AI data-center architecture |
| Workload Management | 23% | Training on Slurm, training on Run:ai, inference on K8s, inference on Run:ai, resource allocation between teams, NGC containers |
| Troubleshooting & Optimization | 23% | Docker, **Fabric Manager** (NVLink/NVSwitch), BCM troubleshooting, **Magnum IO**, storage performance, NGC container deployment |

### Your honest gap analysis

| Topic | Your level | Priority |
|---|---|---|
| Kubernetes | Expert (CKA/CKAD/CKS) | **Low** — only ~15% of exam |
| Docker / containers | Strong | Low |
| Monitoring concepts | Strong (Prometheus/Grafana) | Low-medium — but learn DCGM specifically |
| **BCM** | **Zero** | **HIGHEST — 31% of exam** |
| **Slurm** | **Zero** | **HIGH — appears in 3 of 4 domains** |
| **Run:ai** | **Zero** | **HIGH — appears in 3 of 4 domains** |
| MIG | Concept only | Medium-high |
| Fabric Manager / NVLink / NVSwitch | Concept only | Medium |
| Magnum IO / GPUDirect / storage perf | Low | Medium |
| DOCA / BlueField DPU | Zero | Low-medium (small slice) |

**The one sentence version:** your Kubernetes strength will not carry this exam. BCM, Slurm and Run:ai will decide whether you pass.

---

## 2. Study Materials (No Books)

There is no book for NCP-AIO. Do not buy one. Use these:

### Must have
1. **Official Study Guide PDF** — linked on the NVIDIA NCP-AIO certification page under "Exam Study Guide". Download it on day 1.
2. **BCM Administrator Manual** — `docs.nvidia.com`. This is your main textbook. Long, dry, and 31% of your exam.
3. **Slurm documentation** — `slurm.schedmd.com`
4. **Run:ai documentation** — `run-ai-docs.nvidia.com`
5. **DCGM documentation** — `docs.nvidia.com/datacenter/dcgm`
6. **Fabric Manager User Guide** — `docs.nvidia.com/datacenter/tesla/fabric-manager-user-guide`
7. **NGC catalog + docs** — `catalog.ngc.nvidia.com`

### Optional but valuable
- **NVIDIA AI Operations Professional Workshop** (multi-day, instructor-led, hands-on with DCGM, InfiniBand, BlueField, GPU virtualization). **Ask e& to pay for this.** Frame it as directly supporting the GPU inference work you already do for them. Worst case they say no.
- **AI Infrastructure & Operations Fundamentals** self-paced course — you already have NCA-AIIO, so this is mostly revision. Skim only.

### Practice questions
Use them only in the last 10 days, and only to find weak spots. Do **not** use them as your study method. Third-party "dumps" sites are unreliable and many are outdated — treat any score from them with suspicion.

---

## 3. Building Your Lab

This is the hard part. You need three environments.

### Lab A — Slurm (easy, cheap, do this first)

Slurm runs fine on plain CPU VMs. You do **not** need GPUs to learn Slurm administration.

- 3 small cloud VMs (1 controller + 2 compute), or 3 VMs on your laptop with multipass/Vagrant
- Cost: roughly $10–20, or free locally
- Install and configure from scratch — **do not use a one-click script**. The exam tests whether you can install and configure it.

**What to practise until it's automatic:**
- `slurm.conf` structure, partitions, node definitions
- `sbatch`, `srun`, `salloc`, `squeue`, `sinfo`, `scontrol`, `sacct`
- **GRES configuration for GPUs** (`gres.conf`) — high value, likely lab material
- Node states: draining, drained, down — and how to bring a node back
- QoS, account limits, fair-share basics
- Writing a batch script for a multi-node training job

### Lab B — GPU + Kubernetes + MIG (medium cost)

- Rent a GPU instance (RunPod, Lambda, Vast.ai)
- **Important:** MIG only works on A100 / H100 / A30 class GPUs. An L4 or A10 will **not** let you practise MIG. Budget a few hours on an A100 at roughly $1.50–3.00/hour specifically for MIG.
- Cost: roughly $40–70 total

**What to practise:**
- NVIDIA GPU Operator install on Kubernetes
- `nvidia-smi mig -cgi` / `-dci` — create and destroy MIG instances, list profiles
- MIG strategies in Kubernetes (single vs mixed), GPU time-slicing
- DCGM Exporter, `dcgmi diag`, `dcgmi discovery`, health checks
- Pull and run an NGC container (needs an NGC API key — set that up early)
- Deploy an inference workload on the GPU node

### Lab C — BCM (the hard one)

BCM is licensed enterprise software. This is the main obstacle.

**Do this in week 1, not week 3:**
- Check whether NVIDIA offers a **BCM evaluation / trial licence** or a free tier for a small number of nodes. Apply immediately if so — approval can take days.
- Ask at e& whether the company has any NVIDIA enterprise entitlement. You run H100 inference there; someone in the organisation may already have access.

**If you cannot get access, this is your fallback:**
- Read the BCM Administrator Manual properly — not skimming
- Watch every NVIDIA video and GTC session on BCM and Base View you can find
- Make your own written cheat sheet of `cmsh` commands and Base View navigation
- Accept that you may lose the BCM lab task and must be near-perfect elsewhere

**Be honest with yourself about this.** If you reach week 4 with no BCM hands-on and your practice scores are weak, push the exam back two weeks. There is no prize for failing on schedule at $500 a try.

### Lab D — Run:ai

NVIDIA has open-sourced parts of Run:ai (the KAI Scheduler). Check what is publicly installable on a Kubernetes cluster and deploy it. Even the open components will teach you the concepts: projects, departments, quotas, fair-share, node pools, workload submission.

---

## 4. Week-by-Week Plan (11–13 hours/week)

### Week 1 — Map the exam, start Slurm
- [ ] Create Certiverse account. **Book the exam** for ~5–6 weeks out.
- [ ] Download and read the official Study Guide PDF end to end
- [ ] Apply for BCM evaluation access. Ask e& about NVIDIA entitlements.
- [ ] Create NGC account and API key
- [ ] Build Lab A. Install Slurm from scratch on 3 VMs.
- [ ] Get one `sbatch` job running successfully

**Week 1 output:** exam booked, BCM access request submitted, working Slurm cluster.

### Week 2 — Slurm depth + BCM reading
- [ ] Slurm: GRES/GPU config, partitions, QoS, accounts, node state management
- [ ] Break your Slurm cluster on purpose: node goes down, job stuck in PENDING, wrong partition, out of resources. Fix each one and write down the fix.
- [ ] Begin the BCM Administrator Manual: architecture, head node, node categories, software images, `cmsh` basics
- [ ] Start your own cheat-sheet file: one page per tool

**Week 2 output:** confident in Slurm. BCM concepts clear on paper.

### Week 3 — BCM hands-on + GPU/MIG
- [ ] If BCM access came through: install it. Create node categories. Configure a workload manager. Add users and roles. Sync an image. Use Base View.
- [ ] If not: complete the manual + video plan and finish the cheat sheet
- [ ] Rent A100. Practise MIG: create profiles, destroy them, expose to Kubernetes
- [ ] GPU Operator install, DCGM Exporter, `dcgmi diag`
- [ ] Deploy an NGC container

**Week 3 output:** MIG is automatic. BCM is either hands-on or thoroughly documented.

*This week overlaps with your portfolio project. Do the GPU work once and use it for both.*

### Week 4 — Run:ai + Workload Management
- [ ] Install Run:ai / KAI Scheduler on Kubernetes
- [ ] Create projects and quotas. Submit a training job. Submit an inference workload.
- [ ] Understand how resource sharing between teams works — this is a named blueprint item
- [ ] Submit a training job through Slurm too, so you can compare the two mentally
- [ ] Review AI data-centre architecture: DGX/HGX, NVLink, NVSwitch, InfiniBand vs Ethernet, storage tiers

**Week 4 output:** you can place a workload three different ways (K8s, Slurm, Run:ai).

### Week 5 — Troubleshooting (23% and most forgotten)
- [ ] **Xid errors** — what they are, common codes, how to read them from `dmesg` and DCGM
- [ ] **Fabric Manager** — what it does, why it fails, how to check its service status on NVSwitch systems
- [ ] **Magnum IO / GPUDirect** — RDMA, GPUDirect Storage, NCCL basics. Know what a NCCL failure looks like.
- [ ] **Storage performance** — what makes AI training I/O-bound, checkpoint write patterns
- [ ] Docker troubleshooting: NVIDIA Container Toolkit, runtime not found, driver/CUDA version mismatch
- [ ] NGC container pull failures: auth, tags, architecture mismatch

**Week 5 output:** you can name the likely cause of six different GPU cluster failures.

### Week 6 — Simulate and sit
- [ ] **Full timed run:** 120 minutes. 30 questions in 50 minutes, then 3 lab tasks in 70.
- [ ] Practise questions — target 75%+ before you sit
- [ ] Re-do the three simulated labs below under time pressure
- [ ] Review the whole cheat sheet twice
- [ ] Technical check: camera, microphone, internet, clean room for the proctor
- [ ] Sit the exam

---

## 5. Three Simulated Lab Tasks

Do each one against a stopwatch. **20 minutes each.** This is the closest thing to the real lab.

### Simulation 1 — Slurm GPU job (target 20 min)
> A user reports their GPU training job is stuck in PENDING. The partition shows two nodes DOWN. Bring the nodes back, verify GPU GRES is configured correctly, and submit a 2-node job that requests 1 GPU per node and prints `nvidia-smi` output from each.

Practise until this takes you 10 minutes.

### Simulation 2 — Kubernetes GPU inference (target 20 min)
> The GPU Operator is installed but pods requesting `nvidia.com/gpu` stay Pending. Diagnose it. Then partition the GPU with MIG into 3 instances, expose them to Kubernetes, and deploy an inference container from NGC that lands on one MIG slice.

### Simulation 3 — Troubleshoot a broken node (target 20 min)
> A node reports GPU errors. Use `nvidia-smi`, `dcgmi diag`, `dmesg` and Fabric Manager service status to identify the problem. Check driver and CUDA versions. Verify the NVIDIA Container Toolkit works by running a GPU container. Write a 5-line summary of root cause and fix.

**Writing the 5-line summary matters.** It is also exactly the skill an interviewer tests.

---

## 6. Exam Day

- 30 questions in ~50 minutes. **Do not overthink them.** Flag anything hard and move.
- Leave at least 60 minutes for the 3 labs. The labs are where people run out of time.
- In the labs, get *something* working before you make it perfect. Partial credit beats an elegant half-finished answer.
- If a lab task blocks you completely, leave it and finish the others. Come back if time remains.

---

## 7. Rules

1. **Book the exam today.** Nothing else in this plan works without a fixed date.
2. **BCM access is the critical path.** Chase it in week 1, not week 3.
3. **No books.** Docs and labs only.
4. **If practice scores are below 70% at end of week 5, push the exam two weeks.** $500 and a 14-day retake wait are worse than a delay.
5. **After you pass: no more certifications in 2026.** The project is next.

---

## Cost Summary

| Item | Cost |
|---|---|
| Exam | $500 |
| Slurm VMs | $10–20 |
| GPU time (A100 for MIG + general practice) | $40–70 |
| Portfolio project GPU time (separate) | $50–100 |
| **Total** | **~$600–690** |

Ask e& to cover the exam and the workshop. You are the person running their GPU inference. The business case writes itself.