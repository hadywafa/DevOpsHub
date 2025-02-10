# AWS Certificate Manager (ACM) 📑

AWS Certificate Manager (ACM) is a managed service that helps you **create**, **store**, and **renew** SSL/TLS certificates for securing websites, applications, and APIs. ACM eliminates the need for manual certificate management, making it easier to secure your workloads in AWS.

---

<div align="center">
  <img src="images/acm.png" alt="AWS Certificate Manager" />
</div>

---

## 🌟 **What is AWS Certificate Manager?**

ACM simplifies the use of **SSL/TLS X.509 certificates**, which are essential for:

- **Encrypting data** transmitted between clients and servers.
- Authenticating the identity of websites and applications.

### Key Capabilities

1. **Certificate Issuance**:

   - ACM can issue public or private SSL/TLS certificates for your domains.
   - Supports single domain, multiple specific domains, or **wildcard domains** (e.g., `*.example.com`).

2. **Certificate Import**:

   - You can import existing certificates into ACM if needed.

3. **Automatic Renewal**:
   - ACM automatically renews certificates issued through the service.
   - **Note**: Imported certificates are not automatically renewed.

---

## 🔑 **How AWS Certificate Manager Works**

1. **Request a Certificate**:

   - Specify your domain name(s).
   - ACM validates domain ownership using DNS or email-based validation.

2. **Use the Certificate**:

   - Attach the certificate to supported AWS services like:
     - **Elastic Load Balancer (ELB)**
     - **CloudFront**
     - **API Gateway**
     - **Cognito**
     - **Elastic Beanstalk**
     - **App Runner**
     - **Amplify**
     - **OpenSearch**
     - **CloudFormation**

3. **Automatic Renewal**:

   - ACM ensures certificates issued through ACM remain valid by handling renewals automatically.

4. **Monitor Certificate Status**:
   - Use the ACM Console or **AWS CLI** to check certificate status and manage certificates.

---

## 🔄 **ACM Certificate Types**

| **Certificate Type**      | **Description**                                                                                              |
| ------------------------- | ------------------------------------------------------------------------------------------------------------ |
| **Public Certificates**   | Issued by ACM and trusted by major browsers. Used for internet-facing applications.                          |
| **Private Certificates**  | Issued by ACM Private CA for internal applications or devices within your organization.                      |
| **Wildcard Certificates** | Secures a domain and all its subdomains (e.g., `*.example.com`).                                             |
| **Imported Certificates** | Pre-existing certificates issued by third-party Certificate Authorities (CAs) that can be imported into ACM. |

---

## 🛠️ **How to Use AWS Certificate Manager**

### **Step 1: Requesting a Certificate**

1. **Open ACM** in the AWS Management Console.
2. **Request a certificate**:
   - Choose between public or private certificates.
   - Enter the domain names to secure (e.g., `www.example.com`, `*.example.com`).
3. **Validate Domain Ownership**:
   - Use DNS validation (preferred) or email validation to prove ownership of the domain.

---

### **Step 2: Using the Certificate**

Attach the issued certificate to an AWS service:

- **Elastic Load Balancer (ELB)**: Secure incoming traffic to your backend servers.
- **CloudFront**: Encrypt data for global content delivery.
- **API Gateway**: Protect REST or GraphQL APIs.
- **Cognito**: Secure user pools for authentication.
- **Elastic Beanstalk**: Add SSL/TLS to your web applications.
- **App Runner** and **Amplify**: Secure modern application platforms.

---

### **Step 3: Monitoring and Renewal**

1. **Monitor Certificates**:

   - Check certificate status via the **ACM Console** or **AWS CLI**:

     ```bash
     aws acm list-certificates
     ```

2. **Automatic Renewal**:
   - Certificates issued by ACM are automatically renewed before expiration.
   - **Imported certificates** require manual renewal and re-import.

---

## ⚠️ **Limitations of AWS Certificate Manager**

1. **Export Restrictions**:

   - Public certificates issued by ACM **cannot be exported**.
   - Private certificates issued by **ACM Private CA** can be exported.

2. **Direct Usage on EC2**:

   - ACM certificates **cannot be directly installed on EC2 instances**.
   - Use an ELB or CloudFront in front of the EC2 instance to secure traffic.

3. **No Manual Renewals for ACM-Issued Certificates**:
   - Renewal is automatic, but certificates imported into ACM must be manually managed.

---

## 💡 **Best Practices for Using ACM**

1. **Use DNS Validation**:

   - Simplifies ownership validation and is reusable for renewal.

2. **Monitor Expiration Dates**:

   - Ensure imported certificates are renewed before expiration.

3. **Leverage ACM Private CA**:

   - Use ACM Private CA for internal applications requiring private certificates.

4. **Integrate with Supported Services**:
   - Use ACM certificates with **CloudFront**, **ELB**, or **API Gateway** for seamless SSL/TLS integration.

---

## 🤔 **Why Choose AWS Certificate Manager?**

1. **Ease of Use**:

   - ACM automates certificate provisioning, deployment, and renewal.

2. **Cost-Effective**:

   - Public certificates are free. You only pay for services like ACM Private CA or associated AWS services.

3. **Seamless Integration**:

   - Works out of the box with many AWS services.

4. **Enhanced Security**:
   - Eliminates manual certificate handling, reducing the risk of misconfiguration.

---

## ✅ **Conclusion**

AWS Certificate Manager is a powerful tool for simplifying the management of SSL/TLS certificates. Whether you're securing a public-facing website or an internal application, ACM streamlines the process of issuing, deploying, and renewing certificates. By integrating seamlessly with other AWS services, ACM ensures your applications are protected with minimal effort.
