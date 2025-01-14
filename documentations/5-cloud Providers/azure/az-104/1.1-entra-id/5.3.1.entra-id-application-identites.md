# Entra ID application identities

Application identities in Azure refer to the various ways applications can authenticate and access resources securely. These identities are essential for enabling applications to perform tasks without manual intervention. Here are the main types of application identities in Azure:

## 1. App Registrations

**Purpose**: Provides an identity for any type of application (not just Azure resources) to authenticate and access Azure services and other resources securely.

### **Characteristics:**

- **Client ID and Secret**: When you register an application, you get a unique client ID and secret that the application can use to authenticate.
- **Scope**: Used by any application type, including web apps, mobile apps, APIs, and services.
- **Use Case**:
  - A web application needing to authenticate users and access Azure services like Microsoft Graph API.
  - A third-party application requiring API access to Azure resources.

### **Use Cases:**

- **Use Case 1: Web Application**

  - **Scenario**: You're developing a web application that needs to authenticate users and access Microsoft Graph API to read their emails.
  - **Solution**: Register your web application in Microsoft Entra ID. This provides you with an Application (client) ID and a Directory (tenant) ID. Configure the necessary API permissions to access the Microsoft Graph API.

- **Use Case 2: API Integration**
  - **Scenario**: You have an API that other applications need to call securely.
  - **Solution**: Register your API in Microsoft Entra ID. Other applications will use the registered API's client ID and secret to request tokens for secure access.

### **Authenticate Methods:**

#### 1. **Client Secrets**

- **Usage:** Suitable for web apps, confidential clients.
- **Pros:** Easy to implement.
- **Cons:** Requires secure storage; secrets can expire or be compromised.
- **Best Practices:** Regularly rotate client secrets and store them securely using Azure Key Vault.

#### 2. **Certificates**

- **Usage:** Suitable for high-security applications.
- **Pros:** More secure; certificates can be rotated regularly.
- **Cons:** Requires certificate management.
- **Best Practices:** Use certificates over client secrets for enhanced security and automate certificate rotation.

## 2. Enterprise Applications

**Purpose**: Managing third-party SaaS applications and their SSO configurations.

- **Use Case 1: Single Sign-On (SSO) for SaaS Applications**

  - **Scenario**: Your organization uses Salesforce and wants to enable SSO for employees.
  - **Solution**: Integrate Salesforce as an enterprise application in Microsoft Entra ID. Configure SSO settings so employees can log in to Salesforce using their Microsoft Entra ID credentials.

- **Use Case 2: Access Control for External Applications**
  - **Scenario**: Your organization uses a third-party project management tool.
  - **Solution**: Add the tool as an enterprise application and manage user access through Microsoft Entra ID. Apply conditional access policies to enhance security.

## 3. Managed Identities

**Purpose**: Primarily designed for Azure resources to authenticate to other Azure services securely without managing credentials manually.

### **Types:**

1. **System-Assigned Managed Identity**:

   - **Tied to Resource**: Created as part of an Azure resource, such as a virtual machine or an Azure function.
   - **Lifecycle**: When the resource is deleted, the managed identity is also deleted.
   - **Use Case**: An Azure virtual machine needing to access a storage account, Azure Key Vault, or other Azure services.

2. **User-Assigned Managed Identity**:
   - **Standalone Resource**: Created as a separate Azure resource and can be assigned to one or more Azure resources.
   - **Lifecycle**: Independent of the resources it's assigned to.
   - **Use Case**: Multiple virtual machines or applications requiring access to the same Azure resources, such as a database or storage account.

### **Use Cases:**

- **Use Case 1: Security Monitoring Service**

  - **Scenario**: You want to use a third-party security monitoring service to keep an eye on your Azure resources.
  - **Solution**: Deploy the managed application from Azure Marketplace. The service provider manages the application, and you configure it to monitor your resources.

- **Use Case 2: Data Analytics Platform**
  - **Scenario**: Your organization needs a sophisticated data analytics platform without the overhead of managing the infrastructure.
  - **Solution**: Use a managed application from Azure Marketplace that offers data analytics capabilities. The provider manages the backend, while you use the platform for analytics.

## Summary

- **App Registration**: Ideal for creating identities for your own applications to authenticate and access resources.
- **Enterprise Applications**: Best for managing third-party SaaS applications and enabling SSO for users.
- **Managed Applications**: Suitable for using services provided by third-party vendors, where the application management is handled by the provider.
