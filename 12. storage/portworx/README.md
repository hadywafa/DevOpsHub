# Portworx

- Docs: <https://docs.portworx.com/>

## 🔗 AKS (Azure)

Since you are running an Azure Kubernetes Service (AKS) cluster in the cloud, FlashBlade is completely out of the equation because it is a physical, on-premises hardware appliance. [1, 2, 3]
Instead, your comparison centers on whether to use Portworx Enterprise (via software orchestration) or native cloud features like Azure Files. [1, 4, 5]
To implement a multi-pod shared storage architecture using ReadWriteMany (RWX) within AKS, consider these three available options: [1, 6]

### Option 1: Portworx Enterprise (Recommended for Enterprise Apps)

You can deploy Portworx straight from the Azure Marketplace onto your AKS cluster. [4]

-
- How it works: Portworx attaches standard Azure Managed Disks (like Premium SSDs) to your AKS node pools. It pools those disks together and layers its own software-defined Sharedv4 filesystem on top. [4, 5]
- Why use it: It gives your pods fast file sharing while keeping advanced features like container-granular snapshots, synchronous replication across multiple Azure Availability Zones (AZs), and rapid disaster recovery. [4, 7, 8]
- Best for: Critical stateful workloads (e.g., WordPress clusters, Magento, custom file processing pipelines) requiring tight Kubernetes integration and rapid, local performance. [9]
-

### Option 2: Pure Cloud Block Store + Portworx (The Hybrid Solution)

If your organization standardizes on Pure Storage and wants a shared storage experience that replicates physical hardware capabilities in Azure, you can combine Portworx with Pure Cloud Block Store (CBS). [10, 11]

-
- How it works: Pure CBS is a software version of Pure’s hardware array running natively inside your Azure infrastructure. Portworx acts as the CSI driver to carve out shared storage volumes from CBS and serve them to your AKS pods. [10, 11]
- Best for: Teams migrating on-premises applications to Azure who want consistent data management features (like global deduplication and immutable snapshots) across both environments. [11, 12, 13, 14]
-

### Option 3: Azure Files CSI Driver (The Native Cloud Alternative)

If you want to skip third-party software entirely, you can use the built-in Microsoft storage drivers. [1, 6]

-
- How it works: AKS comes pre-configured with the file.csi.azure.com driver. You request a PVC, and Azure dynamically provisions an Azure Files Premium (NFS/SMB) share in your Azure storage account.
- Best for: General file sharing, basic log aggregation, or legacy applications that require a quick, native cloud setup without managing a separate storage software layer. [1, 5, 6]
-

------------------------------

### Comparison for AKS Shared Storage

| Capability / Metric | Portworx (Sharedv4) | Pure Cloud Block Store + Portworx | Native Azure Files (Premium) |
| --- | --- | --- | --- |
| Architecture | In-cluster storage layer | Cloud-hosted virtual array | Fully managed cloud service |
| Data Efficiency | Local node caching | Global data deduplication | Standard cloud pricing structures |
| Disaster Recovery | Built-in zero-RPO replication | CloudSnap cross-region backup | Azure regional storage replication |
| Licensing | Third-party subscription | Pure Storage license required | Consumption-based Azure billing |

To determine the most effective setup for your team, tell me:

-
- What is the workload or app running on these pods? (e.g., a shared web root, content management system, or database backup tool?)
- Are you looking for a native cloud solution to simplify operations, or do you need advanced enterprise backup/DR features? [4, 12]
-
