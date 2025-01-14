# 🎓 Azure Administrator Associate Certification Guide

## 📑 Table of Contents

1. [👥 Manage Identities and Governance (20-25%)](#H1)
   - [🔐 Administer Identity](#H1-S1)
   - [⚖️ Administer Governance and Compliance](#H1-S2)
   - [🛠️ Administer Azure Resources](#H1-S3)
2. [💾 Implement and Manage Storage (15-20%)](#H3)
   - [📦 Administer Azure Storage](#H2-S1)
3. [💻 Deploy and Manage Azure Compute Resources (20-25%)](#H3)
   - [🖥️ Administer Azure Virtual Machines](#H3-S1)
   - [☁️ Administer PaaS Compute Options](#H3-S2)
4. [🌐 Implement and Maintain Virtual Networking (15-20%)](#H4)
   - [🌉 Administer Virtual Networking](#H4-S1)
   - [🔗 Administer Interconnectivity](#H4-S2)
   - [🚦 Administer Network Traffic](#H4-S3)
5. [📊 Monitor and Maintain Azure Resources (10-15%)](#H5)
   - [🛡️ Administer Data Protection](#H5-S1)
   - [📈 Administer Monitoring](#H5-S2)
6. [📝 Notes](#H6)

## 👥 Manage Identities and Governance (20-25%) <a id="H1"></a>

This section focuses on managing user identities, ensuring governance compliance, and overseeing Azure resources to maintain a secure and efficient environment.

### 🔐 Administer Identity <a id="H1-S1"></a>

- **Microsoft Entra ID**: Formerly known as Azure Active Directory (Azure AD), Microsoft Entra ID is now the cornerstone for identity and access management in Azure.
- **User and Group Management**: Create, manage, and secure user accounts and groups.
- **Authentication Methods**: Implement multi-factor authentication (MFA) and single sign-on (SSO) for enhanced security.
- **Role-Based Access Control (RBAC)**: Assign roles to users to control access to Azure resources.

### ⚖️ Administer Governance and Compliance <a id="H1-S2"></a>

- **Azure Policy**: Define and enforce organizational standards and assess compliance at-scale.
- **Azure Blueprints**: Create repeatable sets of Azure resources that adhere to organizational standards.
- **Resource Locks**: Protect critical resources from accidental deletion or modification.
- **Compliance Standards**: Ensure adherence to industry-specific regulations and standards.

### 🛠️ Administer Azure Resources <a id="H1-S3"></a>

- **Resource Management**: Deploy, manage, and monitor Azure resources using the Azure portal, CLI, or PowerShell.
- **Tags and Resource Groups**: Organize resources for easier management and billing.
- **Azure Resource Manager (ARM)**: Utilize ARM templates for infrastructure as code (IaC) deployments.
- **Cost Management**: Monitor and optimize Azure spending.

## 💾 Implement and Manage Storage (15-20%) <a id="H2"></a>

This section covers the implementation and management of Azure storage solutions to ensure data is stored securely and efficiently.

### 📦 Administer Azure Storage <a id="H2-S1"></a>

- **Storage Accounts**: Create and configure storage accounts for different types of data.
- **Blob Storage**: Manage unstructured data such as documents and media files.
- **File Storage**: Implement shared storage for legacy applications using Azure Files.
- **Disk Storage**: Manage disks for Azure virtual machines, including premium and standard disks.
- **Storage Security**: Implement encryption, access keys, and shared access signatures (SAS) to secure data.

## 💻 Deploy and Manage Azure Compute Resources (20-25%) <a id="H3"></a>

Learn to deploy and manage various compute resources in Azure, including virtual machines and Platform as a Service (PaaS) options.

### 🖥️ Administer Azure Virtual Machines <a id="H3-S1"></a>

- **VM Deployment**: Create and configure Azure VMs using the Azure portal, CLI, or PowerShell.
- **Scaling VMs**: Implement scaling strategies to handle workload changes.
- **VM Monitoring**: Use Azure Monitor to track VM performance and health.
- **Backup and Recovery**: Set up backup solutions and disaster recovery for VMs.

### ☁️ Administer PaaS Compute Options <a id="H3-S2"></a>

- **App Services**: Deploy and manage web apps, mobile app backends, and RESTful APIs.
- **Azure Functions**: Implement serverless computing for event-driven applications.
- **Azure Kubernetes Service (AKS)**: Deploy and manage containerized applications using Kubernetes.
- **Azure Batch**: Run large-scale parallel and high-performance computing applications.

## 🌐 Implement and Maintain Virtual Networking (15-20%) <a id="H4"></a>

This section delves into setting up and maintaining virtual networks to ensure secure and efficient connectivity within Azure.

### 🌉 Administer Virtual Networking <a id="H4-S1"></a>

- **Virtual Networks (VNet)**: Create and manage VNets to securely connect Azure resources.
- **Subnets**: Segment VNets into subnets for better organization and security.
- **Network Security Groups (NSGs)**: Control inbound and outbound traffic to resources.

### 🔗 Administer Interconnectivity <a id="H4-S2"></a>

- **VPN Gateways**: Establish secure connections between on-premises networks and Azure.
- **ExpressRoute**: Implement private connections for higher reliability and faster speeds.
- **VNet Peering**: Connect VNets within the same or different Azure regions.

### 🚦 Administer Network Traffic <a id="H4-S3"></a>

- **Load Balancing**: Distribute incoming traffic across multiple resources for high availability.
- **Traffic Manager**: Direct user traffic to the most appropriate endpoint based on routing methods.
- **Azure Firewall**: Implement a robust firewall solution to protect Azure resources.

## 📊 Monitor and Maintain Azure Resources (10-15%) <a id="H5"></a>

Ensure the health, performance, and security of your Azure environment through effective monitoring and maintenance practices.

### 🛡️ Administer Data Protection <a id="H5-S1"></a>

- **Azure Backup**: Implement backup solutions to protect data against loss.
- **Azure Site Recovery**: Ensure business continuity by replicating workloads to a secondary location.
- **Data Encryption**: Use encryption at rest and in transit to secure data.

### 📈 Administer Monitoring <a id="H5-S2"></a>

- **Azure Monitor**: Collect and analyze telemetry data to monitor resource performance.
- **Log Analytics**: Query and analyze log data for insights and troubleshooting.
- **Alerts and Notifications**: Set up alerts to proactively manage issues.

## 📝 Notes <a id="H6"></a>

- **Microsoft Entra ID**: Azure Active Directory has been rebranded to Microsoft Entra ID. Ensure you use the updated terminology in all services and documentation.
- **Service Naming Updates**: All Azure services previously containing "Azure AD" in their names now reference "Entra ID." For example, "Azure AD Connect" is now "Entra ID Connect."
