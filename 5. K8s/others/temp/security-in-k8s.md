Excellent — this one’s another **KCNA exam classic** that checks your understanding of the two main Kubernetes security focus areas 🔐

---

## 🧠 Question Recap

> **When it comes to securing Kubernetes, which two areas require careful attention and implementation of security measures?**

✅ **Correct Answer:**
👉 **Application security and cluster component security**

---

## 🔍 Explanation

Kubernetes security is divided into **two critical domains**:

### 1. 🧩 **Application Security**

This focuses on protecting **what runs inside the cluster** — your workloads, containers, and application code.

Key aspects:

* Using **secure container images** (scanned and signed)
* Managing **secrets** properly (via Kubernetes Secrets or external secret managers)
* Enforcing **least privilege** via **RBAC** and **PodSecurityStandards**
* Running workloads as **non-root users**
* Using **network policies** to control pod-to-pod communication
* Keeping application dependencies **up to date**

---

### 2. 🧱 **Cluster Component Security**

This focuses on securing **the Kubernetes control plane and nodes themselves**.

Key aspects:

* Securing **etcd**, **API server**, **kube-scheduler**, and **controller-manager**
* Using **TLS** for all communication between control plane components
* Enforcing **RBAC** and **authentication/authorization** for API access
* Keeping Kubernetes **versions updated** and **patching vulnerabilities**
* Restricting access to **kubelet** and **kubectl** commands

---

### ⚠️ Why Not the Other Options?

| Option                                                      | Why It’s Wrong                                                                                                   |
| ----------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------- |
| **Securing the network connections between pods and nodes** | That’s part of **network policies**, which fall *under* application/cluster security — not a separate main area. |
| **Securing physical infrastructure of data center**         | This is the **cloud provider or on-prem responsibility**, not Kubernetes-specific.                               |
| **Securing Kubernetes documentation and knowledge base**    | Not related to runtime or cluster security.                                                                      |

---

## 🧩 Quick KCNA Memory Hook

> Kubernetes security = 🛡️ **App Security + Cluster Security**
> (Everything else — like physical or docs — is out of Kubernetes scope.)

---

✅ **Summary**

* **Application Security:** Protect workloads and pods
* **Cluster Component Security:** Protect Kubernetes control plane and nodes

Together, they define **Kubernetes-native security best practices**.

---

Would you like me to give you a **1-minute KCNA Security Crash Card** (with key tools: Falco, OPA, Kyverno, RBAC, PSPs, Secrets, and Network Policies)? Perfect for last-hour review.
