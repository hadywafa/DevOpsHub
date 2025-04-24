# 🛠️ **AWS Systems Manager (SSM)**

> _Manage, automate, and control infrastructure across AWS and on-premises environments — all from a single interface._

<div align="center">
  <img src="images/ssm-agent-connectivity.png" alt="SSM Agent Connectivity" style="border-radius: 12px; margin-bottom: 20px;" />
</div>

<div align="center">
  <img src="images/ssm-overview.png" alt="SSM Features" style="border-radius: 12px;" />
</div>

---

## 📌 **What is AWS SSM?**

- A **management service** that lets you **control AWS and on-premises infrastructure**.
- It's **agent-based** – the **SSM Agent** communicates with the **AWS Systems Manager endpoint**.
- **Pre-installed** on most **Amazon Linux and Windows AMIs** (older AMIs may require manual setup).

---

## 🧠 **Core Features of AWS Systems Manager**

---

### 🧾 1. **Inventory Management**

- Automatically collects detailed info from your managed instances, such as:
  - Installed apps
  - Network configurations
  - OS patches and hotfixes
  - Hardware specs
  - Running services
  - Custom metadata

---

### 🏃‍♂️ 2. **Run Command**

- Run shell scripts or PowerShell commands across **multiple instances**.
- No SSH required 🔐
- Perfect for automation, updates, patches, or quick fixes.

---

### 🧩 3. **State Management (Desired State)**

> Ensure your instances stay configured the way you want

- Define how an instance should be configured.
- Example: Want port `8080` **blocked**? If someone opens it, SSM will detect & **revert it**.
- Keeps your infrastructure **compliant and secure**.

---

### 🧳 4. **Parameter Store**

> Securely store configuration data and secrets.

- Acts like a **key-value store** for:
  - App settings (e.g., DB connection strings)
  - Secrets (e.g., API keys)
- Supports encryption using **AWS KMS**.
- ❗ For highly sensitive secrets, use **Secrets Manager** (supports auto rotation but is **paid**).

---

### 💻 5. **Session Manager**

> SSH-like access, but **secure and audit-ready**.

- Connect to **EC2 instances**, even in **private VPCs**, **without needing SSH or bastion hosts**.
- Access is controlled via **IAM roles** and **logged via CloudTrail**.
- Great for regulated environments (HIPAA, PCI, etc).
