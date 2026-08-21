# Hady — 60 Day Plan + Long Term Roadmap

**Written:** August 2026 **Window:** 15 Aug 2026 → 15 Oct 2026 (before annual leave) **Goal:** Better job (UAE or Europe), 35,000+ AED or equivalent, and a way out of visa dependency.

---

## The Decision (short version)

|Option|Answer|Why|
|---|---|---|
|Golden Kubestronaut|**No**|11 more exams. Wrong signal. Makes you look like a cert collector, not an AI infra engineer.|
|NCP-AIO|**Yes — 4 weeks, not 8**|Already started. One exam. Points at the job you want.|
|CCAAK (Kafka)|**No**|Aquanow is gone. Weak signal. Learn Kafka from DDIA + hands-on, not an exam.|
|**Public GPU project**|**Yes — this is the main work**|The only thing that proves you can actually run AI infrastructure.|
|Master's (OMSCS)|**Yes — but as background**|Good long-term. Not a job-search accelerator. Timeline is 1 year later than you think.|

**Split of your time: 30% certificate, 70% project.**

---

## Why "Golden Kubestronaut" is a No

It is now **16 certifications**. You have 5. You would need 11 more:

`PCA, ICA, CCA, CAPA, CGOA, CBA, OTCA, KCA, CNPA, CNPE, LFCS`

- CNPE was added on 1 March 2026 and is a **hands-on** exam.
- LFCS is hands-on. ICA is hands-on.
- All 16 must be **active at the same time**.

Even if you could pass all 11 in two months (you can't, with a full-time job), the title says:

> _"I am the most certified Kubernetes generalist in the world."_

You are trying to say:

> _"I run AI infrastructure in production."_

Those are different people. You already have the rare title — **Kubestronaut**. Golden is just the collection.

---

# PART 1 — The Next 60 Days

Three tracks. Track A and B overlap. Track C is 2 hours total.

## Track A — NCP-AIO (Weeks 1–4)

**Rule #1: Book the exam TODAY for a date around 15 September.**

An unbooked exam expands to fill all available time. A booked exam finishes.

### Study plan (10–12 hours/week)

|Week|Focus|How to study|
|---|---|---|
|1|AI infrastructure fundamentals — GPU architecture basics, DGX/HGX systems, NVLink vs PCIe, what an AI cluster actually is|Official NVIDIA exam guide first. Download it before anything else and confirm the real domain list.|
|2|GPU in Kubernetes — GPU Operator, device plugin, MIG partitioning, scheduling, node labelling, time-slicing|**Do it, don't read it.** Install the GPU Operator on a rented GPU node.|
|3|Monitoring + operations — DCGM Exporter, GPU metrics, health checks, troubleshooting, storage and networking for AI workloads|This overlaps 100% with your project. Build the Grafana GPU dashboard here.|
|4|Review + practice questions + weak areas|Do full practice runs. Sit the exam.|

**Important:** Confirm the official exam objectives from NVIDIA's page before you start. Do not study from a random YouTube playlist that may be based on an older version.

**Stop condition:** Once you pass, you are done with certificates for 2026. No exceptions.

---

## Track B — The Public Project (Weeks 3–8)

This is the real deliverable. Name it something clear, e.g. **`gpu-inference-platform`** or **`vllm-on-k8s-benchmarks`**

### What it must contain

1. Kubernetes cluster with a real GPU node
2. NVIDIA GPU Operator installed and working
3. vLLM serving an open model (Llama 3 8B, Qwen, or Mistral)
4. DCGM Exporter → Prometheus → Grafana dashboard showing GPU utilisation, memory, temperature, SM occupancy
5. **Load testing with real numbers**
6. **A written log of things that broke and why**

Point 6 is what makes it different from every tutorial repo on GitHub.

### Where to get a GPU

You probably don't have one at home, and you must **not** use e& infrastructure for a public project.

Rent one. A single L4 or A10G is roughly $0.40–0.80/hour on RunPod, Lambda, or Vast.ai. You need maybe 60–100 hours total.

**Budget: $50–100.** That is the cheapest career investment on this entire page. Cheaper than one certification exam.

### Week by week

**Week 3 — Cluster + GPU**

- Rent GPU instance, install k3s (single node is fine — do not waste time on a fancy multi-node setup)
- Install NVIDIA GPU Operator
- Confirm `nvidia-smi` works inside a pod
- Commit: `README.md` with the goal of the project

**Week 4 — Serving**

- Deploy vLLM with a small model
- Expose it, hit it with curl, get a completion back
- Document every error you hit getting there (there will be many — CUDA version mismatch, model download timeout, insufficient memory)
- Commit: working manifests + `docs/01-setup.md`

**Week 5 — Observability**

- DCGM Exporter → Prometheus
- Grafana dashboard: GPU util, GPU memory used, power draw, temperature
- Add vLLM's own metrics endpoint (queue size, running requests, KV cache usage)
- Commit: dashboard JSON + `docs/02-observability.md`
- _This week also covers your NCP-AIO Week 3 material. Two birds._

**Week 6 — Benchmarks (the most valuable week)**

- Use vLLM's `benchmark_serving.py` or Locust
- Measure at concurrency 1, 4, 16, 64:
    - TTFT (time to first token)
    - TPOT (time per output token)
    - Total throughput (tokens/sec)
    - GPU utilisation at each level
- Make a table. Make a graph.
- Commit: `docs/03-benchmarks.md` with the actual numbers

**Week 7 — Break it on purpose** This is the section that makes senior engineers respect the repo.

- Set `gpu-memory-utilization` too high → OOM. Document the error and the fix.
- Send a request longer than `max-model-len` → document what happens.
- Enable prefix caching → re-run benchmarks → show the difference.
- Kill the pod under load → measure recovery time.
- Commit: `docs/04-failure-modes.md`

**Week 8 — Package it**

- Clean README with architecture diagram, results table at the top
- One LinkedIn post: _"I benchmarked LLM inference on Kubernetes. Here's what surprised me."_ — link the repo, share 2 real numbers
- Update CV: new bullet under a **Projects** section
- Update LinkedIn headline

### The test of whether it worked

Can you answer this, out loud, in English, in 90 seconds?

> _"Your inference service p99 latency doubled overnight. Nothing was deployed. Walk me through your first five minutes."_

If yes, the project did its job.

---

## Track C — Admin (2 hours total, do this week)

- [ ] **Start the Police Clearance Certificate (PCC) + attestation.** From April 2026 this is mandatory for Egyptian nationals for UAE employment and residence visas. Attestation is slow. Having it ready removes weeks from any job change.
- [ ] **Check the German `anabin` database** for Ain Shams University. This tells you whether your existing bachelor's is recognised for an EU Blue Card. Fifteen minutes. More important to your Europe option than the entire master's degree.
- [ ] **Confirm NCP-AIO exam objectives** from NVIDIA's official page.

---

# PART 2 — The Master's (OMSCS)

## Verdict: Do it. But understand exactly what it is.

### What it gives you

- Passes HR filters that require "Master's degree" — no number of certificates does this
- Strong answer to "why sponsor a foreign hire?"
- Cheap (roughly $7,000–8,000 total)
- Georgia Tech is a genuinely respected name

### What it does NOT give you

- **No US pathway.** Online degree = no F-1 visa, no OPT, no H-1B route.
- **Little help for Germany.** The Blue Card cares about your _existing_ degree recognition (see anabin above) plus salary threshold.
- **No short-term job effect.** It is a 2–3 year background process.

### Correct timeline

Deadlines are **March 1** (for Fall start) and **August 15** (for Spring start). Decisions come about 10–12 weeks later.

|Date|What happens|
|---|---|
|Nov 2026|Start gathering documents (NOT January)|
|1 March 2027|Application deadline|
|~May 2027|Decision|
|**August 2027**|You actually start — this is when "MSc @ Georgia Tech" goes on LinkedIn|

**So the credibility boost is 12 months away, not 6.** Do not build your job-search timeline around it.

### Document checklist (start in November)

- [ ] Ain Shams transcripts (official, may need attestation — this is the slow one)
- [ ] ITI diploma documents
- [ ] 3 recommendation letters — Souad should be one. Ask her in **December**, not February.
- [ ] Statement of purpose
- [ ] Check whether you need TOEFL/IELTS or qualify for a waiver based on English-medium instruction
- [ ] Supplemental essay questions

### The honest risk

A master's is a very comfortable place to hide for three years. "I'm studying" feels like progress and postpones being judged by strangers.

**Rule: the master's application does not start until the project is public.**

---

# PART 3 — Geography: The Money Math

You want money _and_ security. These point in opposite directions. Choose knowingly.

||Money|Security|Reality|
|---|---|---|---|
|**UAE**|Best. 35k AED ≈ €103k/year, tax-free|Worst. Visa tied to employer. Currently tied to **TechVista**, not e&|The money play|
|**Germany / NL / Ireland**|Senior platform engineer ≈ €85–95k gross, ~40% tax. Your net roughly halves|Best. Permanent residency → citizenship → never sponsored again|The passport play|
|**USA**|Highest ceiling|Effectively closed without an employer running the H-1B lottery|Not a 2-year plan|

### About the "risk for Egyptians" concern

To be accurate: **there is no nationality ban.** As of July 2026 there was no published UAE restriction on Egyptian nationals. The real 2026 change is the mandatory attested PCC.

**Your actual risk is narrower:** your visa is sponsored by TechVista, not e&. If TechVista loses the contract, your residency goes with it and you get a short grace period.

The protection against that is not a certificate. It is being hireable within 30 days — which means a public portfolio and warm recruiter relationships. You currently have neither.

---

# PART 4 — Long Term Roadmap

|Period|The one thing|
|---|---|
|**Aug – Sep 2026**|NCP-AIO passed. PCC started.|
|**Sep – Oct 2026**|Project public. CV + LinkedIn rewritten around it.|
|**Oct – Dec 2026**|Recruiter outreach: Core42, Presight, Microsoft UAE, ADNOC Digital, Nebius, plus Germany/Netherlands. Second project or deepen the first.|
|**Nov 2026 – Feb 2027**|OMSCS documents assembled. Recommendation letters requested.|
|**1 March 2027**|OMSCS application submitted.|
|**H1 2027**|Change employer. Target: direct hire, not outsourced. This is the real goal.|
|**Aug 2027**|Master's begins, one course per semester, in the background.|
|**2028–2029**|Senior AI Platform Engineer at a real employer. Master's finishing. Decide UAE long-term vs Europe from a position of strength.|

---

# PART 5 — Rules For Myself

1. **No new certificates after NCP-AIO** until the project is public. None.
2. **No new books** until Chapter 5 of the vLLM serving book, read next to a terminal.
3. **The exam is booked before the studying starts.** Always.
4. **Every week the project gets a commit.** Public. Even a bad one.
5. **When I feel the urge to add a new path** (new cert, new tool, new degree, new language) — that urge is the signal that I am avoiding being judged. Note it in Obsidian. Do not act on it for 7 days.
6. **Europe is for the passport. UAE is for the money.** Stop optimising for both in the same decision.

---

## Reading (only if there is time left over — there won't be)

**One book.** _Hands-On LLM Serving and Optimization_ — Chi Wang & Peiheng Hu (O'Reilly, 2026).

Read Chapters 1–5 next to the terminal while building the project. It covers KV cache, prefill/decode, batching, vLLM's architecture, GPU memory bandwidth and arithmetic intensity — exactly the vocabulary you need in interviews.

5 hours/week maximum. Everything else waits.