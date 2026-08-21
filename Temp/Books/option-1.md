Yes. I re-evaluated the roadmap specifically around your preference:

> **You do not want “cookbook” books full of commands. You want books that start with _why the problem exists_, build the mental model, explain how the technology evolved, and then connect the pieces together.**

And I also checked this against what **OpenAI and NVIDIA are hiring for right now**. Current OpenAI compute/inference roles emphasize distributed systems, Kubernetes, GPU hardware behavior, scheduling, networking/RDMA/NCCL, performance debugging, observability, and strong software engineering. NVIDIA’s current DGX Cloud roles similarly combine Kubernetes, distributed systems, GPU scheduling, and systems performance. ([OpenAI](https://openai.com/careers/software-engineer-compute-infrastructure-san-francisco/?utm_source=chatgpt.com "Software Engineer, Compute Infrastructure"))

So I would **change the reading list slightly** from my previous answer.

# The Senior AI Platform Engineer Reading Path

Think of the whole journey as one story:

**How does one program run?**  
↓  
**How do many programs share a machine?**  
↓  
**How do machines communicate?**  
↓  
**How do thousands of machines behave as one system?**  
↓  
**How do we build a programmable platform over those machines?**  
↓  
**What exactly is an AI workload?**  
↓  
**Why does AI need GPUs?**  
↓  
**How do we serve models across GPUs?**  
↓  
**How do we squeeze maximum performance from the entire system?**

That is the story I want you to follow.

|Order|Book|Purpose|“Why/Story” quality|Priority|
|---|---|---|---|---|
|1|**Operating Systems: Three Easy Pieces**|Understand the machine/OS|⭐⭐⭐⭐⭐|Essential|
|2|**Systems Performance, 2E**|Learn to diagnose real systems|⭐⭐⭐⭐|Essential|
|3|**Networking and Kubernetes**|Understand how machines/containers communicate|⭐⭐⭐⭐|Essential|
|4|**Designing Data-Intensive Applications, 2E**|Learn distributed-systems thinking|⭐⭐⭐⭐⭐|Essential|
|5|**Learning Go, 2E**|Become a platform software engineer|⭐⭐⭐⭐|Essential|
|6|**Kubernetes Programming with Go**|Build Kubernetes, not merely operate it|⭐⭐⭐|Essential|
|7|**AI Engineering — Chip Huyen**|Understand the modern AI system|⭐⭐⭐⭐⭐|Essential|
|8|**Build a Large Language Model From Scratch**|Understand what your platform is actually running|⭐⭐⭐⭐⭐|Selective|
|9|**Programming Massively Parallel Processors, 4E**|Understand GPUs and parallel compute|⭐⭐⭐⭐|Essential|
|10|**Hands-On LLM Serving and Optimization**|Learn production inference|⭐⭐⭐⭐⭐|Essential|
|11|**AI Systems Performance Engineering**|Connect the entire stack at senior level|⭐⭐⭐⭐|Final/Reference|

And there is a reason for **exactly this order**.

---

## 1. Operating Systems: Three Easy Pieces

### Remzi & Andrea Arpaci-Dusseau

**Start here.**

This is actually a better first book for _you_ than starting directly with Brendan Gregg.

The entire book is organized around three questions:

> How does the OS virtualize resources?  
> How does concurrent execution work?  
> How does data persist?

The authors organize operating systems around **virtualization, concurrency, and persistence**, explicitly building those concepts as the three major themes. ([UW Computer Sciences](https://pages.cs.wisc.edu/~remzi/OSTEP/?utm_source=chatgpt.com "Operating Systems: Three Easy Pieces"))

You finally understand:

```text
Program
   ↓
Process
   ↓
Thread
   ↓
Scheduler
   ↓
CPU

Virtual Memory
   ↓
Page Tables
   ↓
Physical Memory

Application
   ↓
System Call
   ↓
Kernel
   ↓
Hardware
```

And suddenly concepts you already use every day start making deeper sense:

```text
Docker namespaces
cgroups
Kubernetes CPU requests
memory limits
OOMKilled
process scheduling
filesystem I/O
containers
```

### Why I think you'll like it

It's unusually conversational for a systems textbook.

It frequently asks:

> Why would we need this?

before explaining:

> Here's how operating systems solved it.

That's exactly your preferred learning style.

### Important

**Do not read every chapter.**

Focus heavily on:

- processes
    
- scheduling
    
- virtual memory
    
- concurrency
    
- locks
    
- I/O
    
- filesystems
    

And another advantage: the authors make the book available free online. ([UW Computer Sciences](https://pages.cs.wisc.edu/~remzi/OSTEP/?utm_source=chatgpt.com "Operating Systems: Three Easy Pieces"))

---

# 2. Systems Performance, 2nd Edition

## Brendan Gregg

Now you understand **how the machine works**.

The next question becomes:

> Why is the machine slow?

That's Brendan Gregg.

The book covers CPU, memory, filesystems, disks, networking, observability methodology and real system-performance analysis. ([O'Reilly Media](https://www.oreilly.com/library/view/systems-performance-2nd/9780136821694/?utm_source=chatgpt.com "Systems Performance, 2nd Edition [Book]"))

This is where you stop debugging like this:

```bash
kubectl get pods
kubectl logs
restart pod
```

and start thinking:

```text
What is the workload?

CPU bound?
Memory bound?
I/O bound?
Lock contention?
Scheduler delay?
Page faults?
Network latency?
Queueing?
```

Eventually an AI inference system might show:

```text
GPU utilization       37%
CPU utilization       97%
P99 latency           7 seconds
GPU memory            92%
queue depth           increasing
```

A senior engineer doesn't say:

> "Add another GPU."

He asks:

> **Where is the bottleneck?**

That mindset is what this book teaches.

OpenAI's current compute and inference roles explicitly emphasize debugging performance across systems, hardware and distributed infrastructure. ([OpenAI](https://openai.com/careers/software-engineer-compute-infrastructure-san-francisco/?utm_source=chatgpt.com "Software Engineer, Compute Infrastructure"))

---

# 3. Networking and Kubernetes

## James Strong & Vallery Lancey

Now we have one machine.

Let's connect two machines.

Then 100.

Then 10,000.

This book has a particularly useful progression:

```text
Networking fundamentals
        ↓
Linux networking
        ↓
containers
        ↓
CNI
        ↓
Kubernetes networking
        ↓
cloud networking
```

That's almost exactly its chapter progression. ([O'Reilly Media](https://www.oreilly.com/library/view/networking-and-kubernetes/9781492081647/?utm_source=chatgpt.com "Networking and Kubernetes [Book]"))

You'll finally connect:

```text
packet
TCP
socket
interface
routing
bridge
veth
namespace
iptables
conntrack
CNI
kube-proxy
Service
LoadBalancer
```

into **one mental model**.

Later, AI infrastructure adds:

```text
RDMA
RoCE
InfiniBand
NVLink
NCCL
GPUDirect
```

And those concepts become much easier because the networking foundation already exists.

OpenAI's current compute roles explicitly mention large-scale networking, RDMA and NCCL as relevant specialization areas. ([OpenAI](https://openai.com/careers/software-engineer-compute-infrastructure-san-francisco/?utm_source=chatgpt.com "Software Engineer, Compute Infrastructure"))

---

# 4. Designing Data-Intensive Applications — 2nd Edition

## Martin Kleppmann & Chris Riccomini

### This may become your favorite book.

If there is **one book in this roadmap that perfectly matches your “tell me the story and why” preference**, it is DDIA.

The new second edition covers trade-offs in system architecture, nonfunctional requirements, storage, replication, partitioning and distributed systems. ([O'Reilly Media](https://www.oreilly.com/library/view/designing-data-intensive-applications/9781098119058/?utm_source=chatgpt.com "Designing Data-Intensive Applications, 2nd Edition [Book]"))

It doesn't mainly teach:

```text
Kafka command X
Database Y
Tool Z
```

It asks:

> Why do we replicate data?

Then:

> What happens if replicas disagree?

Then:

> What does consistency actually mean?

Then:

> What happens when nodes fail?

Then:

> What trade-off did different systems choose?

That's **engineering thinking**.

You'll understand:

```text
replication
partitioning
consensus
leader election
quorum
transactions
consistency
idempotency
retries
backpressure
streaming
failure
```

This is one of the biggest differences between:

> Senior DevOps Engineer

and:

> **Senior Infrastructure / Platform Software Engineer.**

OpenAI currently describes relevant candidates as people who have built or operated distributed systems, infrastructure platforms, Kubernetes clusters or demanding production systems. ([OpenAI](https://openai.com/careers/software-engineer-compute-infrastructure-san-francisco/?utm_source=chatgpt.com "Software Engineer, Compute Infrastructure"))

---

# 5. Learning Go, 2nd Edition

## Jon Bodner

At this point the story changes.

Until now:

> You understood systems.

Now:

> **You start building infrastructure software.**

You already know programming, so don't waste months relearning computer science through Go.

You need:

```text
Go philosophy
structs
interfaces
errors
goroutines
channels
context
concurrency
testing
HTTP
gRPC
```

The objective isn't:

> "Hady knows Go."

The objective is:

> **Hady can build control-plane software.**

Because top AI infrastructure organizations are hiring **software engineers**, not merely infrastructure configuration specialists.

For example, current OpenAI infrastructure roles explicitly call for strong production software skills in languages such as Python, C++, Go or Rust. ([OpenAI](https://openai.com/careers/software-engineer-gpt-infrastructure-san-francisco/?utm_source=chatgpt.com "Software Engineer, GPT Infrastructure"))

---

# 6. Kubernetes Programming with Go

## Philippe Martin

This is the moment Kubernetes changes meaning for you.

Today you may think:

```text
Deployment
Service
ConfigMap
Helm
ArgoCD
```

After this book you start thinking:

```text
Kubernetes API
API machinery
client-go

CRD
↓
Controller
↓
Watch
↓
Desired state
↓
Reconcile
↓
Actual state
```

The book covers the Kubernetes API, API machinery, client-go, CRDs, controller-runtime, reconcile loops and Kubebuilder operators. ([O'Reilly Media](https://www.oreilly.com/library/view/kubernetes-programming-with/9781484290262/?utm_source=chatgpt.com "Programming Kubernetes Clients and Operators Using Go ..."))

This distinction is **extremely important**.

Junior/mid platform engineers:

> use Kubernetes.

Senior platform engineers increasingly:

> **build abstractions on Kubernetes.**

This is exactly where I'd have you build something like:

```yaml
apiVersion: ai.hady.dev/v1
kind: ModelDeployment

spec:
  model: llama
  gpu:
    count: 2

  autoscaling:
    min: 1
    max: 8

  serving:
    engine: vllm
```

Your controller could create:

```text
Inference workload
Service
GPU resources
autoscaling
ServiceMonitor
PDB
routing
```

Now you're building **AI Platform software**.

---

# 7. AI Engineering

## Chip Huyen

Only now do I want you deeply entering AI.

Why?

Because your job isn't:

> develop another chatbot.

It's:

> **build the infrastructure that AI engineers depend on.**

Chip Huyen starts by defining the emerging AI engineering stack around foundation models and then connects model usage with evaluation, serving, latency, cost and application architecture. ([O'Reilly Media](https://www.oreilly.com/library/view/ai-engineering/9781098166298/?utm_source=chatgpt.com "AI Engineering [Book]"))

You'll build the conceptual map:

```text
Foundation Model
      ↓
Tokens
      ↓
Context
      ↓
Embeddings
      ↓
RAG
      ↓
Fine-tuning
      ↓
Evaluation
      ↓
Inference
      ↓
AI Application
```

You need to understand your **customer's workload**.

If an ML engineer says:

> Llama 70B, BF16, 32K context, TP=8

you should eventually be able to reason about what that means for:

```text
GPU memory
compute
latency
network
parallelism
capacity
cost
```

---

# 8. Build a Large Language Model (From Scratch)

## Sebastian Raschka

This one is different.

I'm **not** trying to turn you into an ML researcher.

I want to remove the AI black box.

The book deliberately walks through building a GPT-like LLM from the ground up. ([Manning Publications](https://www.manning.com/books/build-a-large-language-model-from-scratch?utm_source=chatgpt.com "Build a Large Language Model (From Scratch)"))

You'll see:

```text
text
 ↓
tokenization
 ↓
embeddings
 ↓
attention
 ↓
transformer blocks
 ↓
model
 ↓
training
 ↓
inference
```

Then things like:

```text
KV cache
context length
batch size
quantization
tensor shapes
memory consumption
```

stop being magic words.

### But:

Don't read this book with the goal of becoming an ML engineer.

Read enough to answer:

> **What is actually happening inside the workload my infrastructure is running?**

That's all we need.

---

# 9. Programming Massively Parallel Processors — 4th Edition

## Hwu, Kirk & El Hajj

Now our story reaches the GPU.

Why did AI move from CPU → GPU?

Why does memory bandwidth matter?

Why is parallelism useful?

Why can a GPU have massive compute capacity but still perform badly?

This book explicitly teaches both parallel-programming concepts and GPU architecture. ([O'Reilly Media](https://www.oreilly.com/library/view/programming-massively-parallel/9780323984638/?utm_source=chatgpt.com "Programming Massively Parallel Processors, 4th Edition"))

You want to understand:

```text
CPU
vs
GPU

cores
SMs
warps
threads
blocks

HBM
memory hierarchy
memory bandwidth

PCIe
GPU memory
parallel execution
```

Not because you'll spend your career writing CUDA kernels.

But because later you will encounter:

```text
GPU utilization = 40%
memory bandwidth = saturated
```

and you need to understand why:

> **more compute doesn't necessarily mean more throughput.**

---

# 10. Hands-On LLM Serving and Optimization

## Chi Wang & Peiheng Hu

### This is the most important AI-specific book in your roadmap.

It was published in **April 2026**, and it is remarkably close to the exact specialization we're targeting. ([O'Reilly Media](https://www.oreilly.com/library/view/hands-on-llm-serving/9798341621480/ch03.html?utm_source=chatgpt.com "Hands-On LLM Serving and Optimization"))

The book starts with:

> Why model serving?

then moves into:

```text
Model lifecycle
      ↓
Inference
      ↓
LLM serving
      ↓
batching
      ↓
streaming
      ↓
vLLM
      ↓
single-model serving
      ↓
multi-model serving
      ↓
Triton
      ↓
latency vs throughput
      ↓
optimization
```

The actual contents include building serving services, batching, streaming, vLLM and NVIDIA Triton, along with design trade-offs for multi-model serving. ([O'Reilly Media](https://www.oreilly.com/library/view/hands-on-llm-serving/9798341621480/ch01.html?utm_source=chatgpt.com "Hands-On LLM Serving and Optimization"))

This is where all the earlier books converge.

Think about it:

### Operating Systems taught you

```text
memory
processes
scheduling
```

### Networking taught you

```text
communication
latency
bandwidth
```

### DDIA taught you

```text
distributed systems
failures
scaling
```

### Kubernetes Programming taught you

```text
orchestration
control planes
```

### AI Engineering taught you

```text
AI workloads
```

### GPU book taught you

```text
accelerated compute
```

Now LLM Serving asks:

> **How do I combine all of them into an inference system?**

This is exactly the story you're looking for.

And it aligns unusually well with current OpenAI inference work, where roles mention vLLM/Triton, GPU-backed model-serving infrastructure, latency/throughput, distributed inference and GPU efficiency. ([OpenAI](https://openai.com/careers/software-engineer-inference-amd-gpu-enablement-san-francisco/?utm_source=chatgpt.com "Software Engineer, Inference – AMD GPU Enablement"))

---

# 11. AI Systems Performance Engineering

## Chris Fregly

**Don't start with this.**

Finish with it.

It's over 1,000 pages and was published in November 2025. ([O'Reilly Media](https://www.oreilly.com/library/view/ai-systems-performance/9798341627772/?utm_source=chatgpt.com "AI Systems Performance Engineering [Book]"))

I view this as your:

> **Senior AI Infrastructure reference book.**

Because by this stage you finally have enough context to connect:

```text
Application
    ↓
Inference server
    ↓
Model runtime
    ↓
CUDA
    ↓
GPU
    ↓
GPU memory
    ↓
Network
    ↓
Node
    ↓
Kubernetes
    ↓
Cluster
```

Then you can ask the real senior-level question:

> Where is the bottleneck **across the entire stack**?

The book specifically covers optimizing AI-system performance across layers, including GPU memory access and broader hardware/software optimization. ([O'Reilly Media](https://www.oreilly.com/library/view/ingenierie-des-performances/0642572281502/?utm_source=chatgpt.com "Ingénierie des performances des systèmes d'IA (French ..."))

That's very close to the type of first-principles performance reasoning OpenAI currently describes for its inference-performance roles. ([OpenAI](https://openai.com/careers/software-engineer-inference-performance-optimization-san-francisco/?utm_source=chatgpt.com "Software Engineer, Inference - Performance Optimization"))

---

# The important change from my previous recommendation

I previously put:

> **Systems Performance first.**

After reconsidering your learning style, I would now do:

> **OSTEP → Systems Performance**

because you specifically enjoy understanding the history/problem/why before learning diagnostic techniques.

Similarly, I would **not start with CUDA, NVIDIA docs, vLLM docs, KServe docs, GPU Operator docs, etc.**

Those are excellent implementation references.

But they don't give you the connected story you want.

Books build:

> **mental models**

Documentation later gives:

> **current implementation details**

That's a much better learning strategy for you.

---

# What I would NOT read now

I would skip books centered primarily on:

**Kubeflow, MLflow, Airflow, Spark, generic MLOps, LangChain, prompt engineering, data engineering, Terraform, basic Kubernetes, basic cloud, certification preparation.**

They aren't bad.

They're simply not the bottleneck between you and the type of engineering NVIDIA/OpenAI are hiring for.

Current OpenAI GPU infrastructure work, for example, involves scheduling and quota systems, Kubernetes cluster provisioning, model deployment/training infrastructure, GPU fleet reliability and software automation. ([OpenAI](https://openai.com/careers/software-engineer-fleet-infrastructure-san-francisco/?utm_source=chatgpt.com "Software Engineer, Fleet Infrastructure"))

NVIDIA's current DGX Cloud roles similarly emphasize Kubernetes, distributed systems and GPU resource scheduling. ([NVIDIA Careers](https://nvidia.wd5.myworkdayjobs.com/en-US/NVIDIAExternalCareerSite/job/Principal-Software-Engineer--Distributed-Systems-Engineer---DGX-Cloud_JR2018153?utm_source=chatgpt.com "Software Engineer, Distributed Systems Engineer - DGX Cloud"))

That's a much deeper systems/software profile than generic MLOps.

---

# One critical reality about OpenAI/NVIDIA

For **FAANG-level / frontier-AI infrastructure engineering**, books alone aren't sufficient.

There's another transformation you need:

```text
DevOps Engineer
      ↓
Platform Engineer
      ↓
Systems / Infrastructure
Software Engineer
      ↓
AI Platform Engineer
```

OpenAI's current compute-infrastructure description is almost a perfect definition of the destination: systems connecting accelerators, CPUs, networking, storage, orchestration, developer tooling and observability into one coherent compute platform. ([OpenAI](https://openai.com/careers/software-engineer-compute-infrastructure-san-francisco/?utm_source=chatgpt.com "Software Engineer, Compute Infrastructure"))

And OpenAI explicitly says candidates can specialize differently—systems performance, networking, GPU behavior, scheduling, Kubernetes/platform UX, etc.—rather than requiring everyone to be expert in every layer. ([OpenAI](https://openai.com/careers/software-engineer-compute-infrastructure-san-francisco/?utm_source=chatgpt.com "Software Engineer, Compute Infrastructure"))

That's important.

You **do not need to become simultaneously**:

- Linux kernel engineer
    
- network engineer
    
- CUDA compiler engineer
    
- ML researcher
    
- HPC expert
    
- Kubernetes maintainer
    

You need broad understanding across the stack and **one or two areas of real depth**.

For you, I would make those:

> **Platform/Distributed Systems + AI Inference Infrastructure**

with GPU performance as the connecting specialization.

---

# If you ask me: “Hady, what do I buy today?”

Don't buy eleven books.

### Buy these four first:

**1. Operating Systems: Three Easy Pieces**  
Actually free digitally; buy physical if you enjoy paper. ([UW Computer Sciences](https://pages.cs.wisc.edu/~remzi/OSTEP/?utm_source=chatgpt.com "Operating Systems: Three Easy Pieces"))

**2. Systems Performance, 2nd Edition**

**3. Designing Data-Intensive Applications, 2nd Edition**

**4. Hands-On LLM Serving and Optimization**

Why book #4 already?

Not to read immediately.

Keep it as the **destination book**.

While you're reading:

```text
Operating Systems
↓
Performance
↓
Networking
↓
Distributed Systems
```

you'll know exactly what you're building toward:

```text
LLM inference
↓
GPU
↓
distributed serving
↓
AI Platform
```

That makes the entire learning journey one connected story instead of another endless list of technologies.

## My final curriculum for you

```text
                    AI PLATFORM ENGINEER

                           ▲
                           │
              AI Systems Performance
                           │
             LLM Serving & Optimization
                           │
                    GPU Computing
                           │
            How LLMs Actually Work
                           │
                    AI Engineering
                           │
             Kubernetes Programming
                           │
                           Go
                           │
                 Distributed Systems
                           │
                    Networking
                           │
                 Systems Performance
                           │
                  Operating Systems
                           │
                     HARDWARE
```

**That is the reading ladder I would use if the target were OpenAI, NVIDIA, Google DeepMind, Meta AI, Anthropic, Microsoft AI, or similar top-tier AI infrastructure organizations.**

And in your case, it is much more valuable than reading another ten DevOps/Kubernetes books, because the missing jump is no longer **“learn more tools.”** It's **“become a stronger systems/software engineer who understands AI compute.”**