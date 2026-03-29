# 📃 **K8s KEPs**

[🔗 References](https://www.youtube.com/watch?v=B810TDzTQsQ)

---

## 🧠 What Are **K8s KEPs** (Kubernetes Enhancement Proposals)?

> **KEP (Kubernetes Enhancement Proposal)** is a formal design document that describes a **proposed change, feature, or improvement** to Kubernetes.

It’s **how new features or major changes are proposed, discussed, and approved** within the Kubernetes community — similar to how Python uses PEPs or AWS uses RFCs.

---

## 🏗️ Purpose of KEPs

KEPs exist to:

- Make Kubernetes **development transparent**
- Ensure **consistency** in design decisions
- Allow **community feedback and review** before implementation
- Track the **lifecycle** of new features — from idea → alpha → beta → GA → deprecation

---

## 🧩 Structure of a KEP

A KEP usually includes sections like:

| Section                      | Description                                           |
| ---------------------------- | ----------------------------------------------------- |
| **Title & Number**           | Unique ID and name of the proposal                    |
| **Authors / SIG Owners**     | Who is responsible (usually a Special Interest Group) |
| **Summary / Motivation**     | What problem the KEP solves and why                   |
| **Proposal**                 | Detailed technical design and behavior                |
| **Graduation Criteria**      | How the feature will move from alpha → beta → GA      |
| **Drawbacks / Alternatives** | Risks and tradeoffs                                   |
| **Implementation History**   | Milestones and tracking                               |

📍 Example:
KEP-1287 → _Pod Overhead accounting_
KEP-3573 → _Job Tracking with Indexed Jobs_

---

## 🧩 KEP Lifecycle

```mermaid
graph LR
A[Idea / Draft] --> B[Review by SIG]
B --> C[Provisional Approval]
C --> D[Implementation]
D --> E[Alpha Release]
E --> F[Beta Release]
F --> G[GA (Stable)]
G --> H[Deprecation or Removal]
```

Each phase is tracked via the KEP document and GitHub discussions.

---

## 🧠 Where KEPs Live

All KEPs are stored in the **Kubernetes/enhancements** GitHub repo:
👉 [https://github.com/kubernetes/enhancements](https://github.com/kubernetes/enhancements)

Each KEP has a number and is organized by **SIG ownership**, like:

```ini
keps/
 ├── sig-node/
 │   └── 1287-pod-overhead/
 ├── sig-api-machinery/
 │   └── 1802-server-side-apply/
```

---

## 💬 Real KCNA Question Angle

You might see something like:

> “What is the purpose of Kubernetes Enhancement Proposals (KEPs)?”
>
> ✅ **Answer:** To standardize and document new feature proposals and changes in Kubernetes, ensuring community review and governance transparency.

---

## 🧠 Summary Cheat Card

| Term          | Meaning                                                  |
| ------------- | -------------------------------------------------------- |
| **KEP**       | Kubernetes Enhancement Proposal                          |
| **Purpose**   | To document, discuss, and track major Kubernetes changes |
| **Owned By**  | Kubernetes Special Interest Groups (SIGs)                |
| **Repo**      | `kubernetes/enhancements` on GitHub                      |
| **Lifecycle** | Idea → Alpha → Beta → GA → Deprecated                    |
