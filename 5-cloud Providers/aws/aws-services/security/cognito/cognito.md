# AWS Cognito 🪪 🔐

Amazon Cognito provides **authentication**, **authorization**, and **user management** for web and mobile applications. It simplifies identity management by offering two core components: **Cognito User Pools** for authentication and **Cognito Identity Pools** for authorization.

---

## 🏗 **Core Components of AWS Cognito**

1. **Cognito User Pools**

   - Provides a **user directory** to manage sign-up and sign-in for your application users.
   - Focused on **authentication** (who a user is).

2. **Cognito Identity Pools**
   - Grants **temporary AWS credentials** to users for accessing AWS services.
   - Focused on **authorization** (what a user can access).

These components can be used **individually** or **together** based on your application's needs.

---

## 🔑 **Cognito User Pools: Authentication**

<div align="center">
  <img src="images/aws-cognito-user-pools.gif" alt="Cognito User Pools" />
</div>

Cognito User Pools are primarily used for **user authentication**:

- Enables **sign-up** and **sign-in** functionality for application users.
- **User Management**: Stores user profiles and manages user directories.
- **Customizable UI**: Provides a hosted web interface for user authentication flows.

### **Features:**

1. **Social Sign-In**:

   - Integrates with identity providers (IdPs) like **Google**, **Facebook**, **Amazon**, **Apple**, and custom IdPs via **OIDC** or **SAML**.
   - Grants authenticated users **JSON Web Tokens (JWTs)** for session management.

2. **Advanced Security Features**:

   - Multi-Factor Authentication (**MFA**).
   - **Compromised Credential Checks**: Detects and notifies users about compromised credentials.
   - **Account Takeover Protection**: Enhances security against malicious logins.

3. **User Verification**:
   - Email and phone verification during the sign-up process.

---

## 🏠 **Cognito Identity Pools: Authorization**

<div align="center">
  <img src="images/aws-cognito-identity-pools.gif" alt="Cognito Identity Pools" />
</div>

Cognito Identity Pools are designed to handle **authorization**, enabling applications to grant users **temporary AWS credentials** for accessing AWS services.

### **How It Works:**

1. **Token Exchange**:

   - Identity pools exchange authentication tokens (from User Pools or other IdPs) for **AWS STS (Security Token Service)** credentials.
   - These credentials grant temporary, scoped access to AWS services.

2. **Federated Identities**:

   - Supports integration with **third-party IdPs**, such as:
     - Social platforms: **Facebook**, **Google**, **Amazon**, **Apple**.
     - Enterprise IdPs: **SAML 2.0** or **OIDC**.

3. **Role-Based Access Control**:
   - Assign IAM roles dynamically based on the identity of the user.
   - Example: Authenticated users receive one role, while unauthenticated users receive another.

---

## 🤔 **Key Differences Between User Pools and Identity Pools**

| Feature                    | **Cognito User Pools**                 | **Cognito Identity Pools**                                                   |
| -------------------------- | -------------------------------------- | ---------------------------------------------------------------------------- |
| **Purpose**                | Authentication: Verify user identity.  | Authorization: Provide AWS credentials for resource access.                  |
| **Output**                 | JSON Web Tokens (JWTs).                | Temporary AWS credentials via STS.                                           |
| **Integration with AWS**   | Focused on managing application users. | Grants access to AWS services like S3, DynamoDB, and others.                 |
| **Social Sign-In Support** | Supported (via hosted UI or APIs).     | Supported, as tokens are passed to identity pools for credential generation. |
| **Usage Scenario**         | Login systems for apps and websites.   | Access control for AWS resources like files in S3 or DynamoDB tables.        |

---

## 🧩 **Using User Pools and Identity Pools Together**

To combine **authentication** and **authorization**, use **Cognito User Pools** to authenticate users and pass their JWTs to **Identity Pools** for authorization.  
For example:

1. A user signs in through a User Pool.
2. The User Pool returns a JWT.
3. The JWT is exchanged with an Identity Pool for temporary AWS credentials.
4. The user accesses AWS resources like **S3** or **DynamoDB**.

---

## ✅ **Conclusion**

AWS Cognito simplifies user management by offering **User Pools** for authentication and **Identity Pools** for authorization. Whether you're building a web application with social sign-ins or a mobile app requiring AWS service access, Cognito provides a scalable and secure solution for handling identity management in the cloud. By combining these components, you can create a seamless and secure authentication and authorization workflow.
