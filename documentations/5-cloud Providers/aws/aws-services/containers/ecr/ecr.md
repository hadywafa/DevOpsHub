# 🗳️ Amazon Elastic Container Registry (ECR)

Amazon Elastic Container Registry (ECR) is a **fully managed container image registry** that enables developers to store, manage, and deploy Docker container images securely and at scale.

---

## 🌟 **Key Features**

### 1. **Fully Managed**

- AWS ECR handles infrastructure, scaling, and management of the container image registry.

### 2. **Secure Storage**

- **Data Encryption**: Encrypts images at rest using **AWS KMS** and in-transit using HTTPS.
- **Access Control**: Use **IAM roles and policies** to control access to ECR repositories.

### 3. **Integration with AWS Services**

- Seamlessly integrates with **Amazon ECS**, **EKS**, **AWS Fargate**, **AWS CodePipeline**, and other AWS services.

### 4. **Built-in Image Scanning**

- Scans images for vulnerabilities and provides detailed findings.

### 5. **Lifecycle Management**

- Automatically deletes old or unused images to save costs.

---

## 🛠️ **How to Use ECR as a Developer**

### **Step 1: Ensure Proper IAM Permissions**

1. **From an AWS Instance**:

   - Attach an **IAM role** to the instance executing the push or pull commands.
   - The IAM role should include the necessary permissions to interact with ECR.

2. **From a Developer Machine**:

   - The developer must have an **IAM policy** attached to their user account to push or pull images.
   - Example IAM Policy:

     ```json
     {
       "Version": "2012-10-17",
       "Statement": [
         {
           "Effect": "Allow",
           "Action": [
             "ecr:BatchCheckLayerAvailability",
             "ecr:CompleteLayerUpload",
             "ecr:DescribeRepositories",
             "ecr:GetAuthorizationToken",
             "ecr:InitiateLayerUpload",
             "ecr:PutImage",
             "ecr:UploadLayerPart"
           ],
           "Resource": "*"
         }
       ]
     }
     ```

---

### **Step 2: Create an ECR Repository**

1. Open the **ECR console**.
2. Click **Create Repository**.
3. Provide a repository name (e.g., `my-app-repo`).
4. Configure repository settings (e.g., encryption, scanning).
5. Click **Create Repository**.

---

### **Step 3: Authenticate Docker with ECR**

- Use the AWS CLI to authenticate Docker with ECR:

  ```bash
  aws ecr get-login-password --region <region> | docker login --username AWS --password-stdin <aws_account_id>.dkr.ecr.<region>.amazonaws.com
  ```

- Replace `<region>` and `<aws_account_id>` with your values.

---

### **Step 4: Push Images to ECR**

1. Tag the Docker image:

   ```bash
   docker tag my-app:latest <aws_account_id>.dkr.ecr.<region>.amazonaws.com/my-app-repo:latest
   ```

2. Push the image:

   ```bash
   docker push <aws_account_id>.dkr.ecr.<region>.amazonaws.com/my-app-repo:latest
   ```

---

### **Step 5: Pull Images from ECR**

To deploy the image, pull it from ECR:

```bash
docker pull <aws_account_id>.dkr.ecr.<region>.amazonaws.com/my-app-repo:latest
```

---

## 🔐 **IAM Requirements Recap**

1. **AWS Instance**:

   - Ensure the **IAM role** attached to the instance includes ECR permissions for actions like pushing or pulling images.

2. **Developer Machines**:
   - Developers must have **IAM policies** allowing ECR actions. For example:
     - `ecr:GetAuthorizationToken`: To authenticate Docker.
     - `ecr:PutImage`: To push images.
     - `ecr:BatchGetImage`: To pull images.

---

## ✅ **Best Practices for Developers**

1. **Secure Access**:

   - Use **least privilege IAM policies** for roles and users.
   - Regularly rotate credentials for security.

2. **Automate with CI/CD**:

   - Use tools like **AWS CodePipeline** to automate pushing and pulling images.

3. **Tagging Strategy**:

   - Use consistent and meaningful tags like `v1.0`, `prod`, `staging`.

4. **Enable Scanning**:

   - Turn on **image scanning** to identify vulnerabilities in your images.

5. **Lifecycle Policies**:
   - Automatically clean up old or unused images with lifecycle rules.

---

## 📚 **Conclusion**

Amazon ECR simplifies the management of container images by providing a secure, scalable, and integrated registry service. By ensuring proper IAM roles or policies, developers can efficiently push and pull images while maintaining strong access controls. With features like lifecycle management and vulnerability scanning, ECR empowers developers to focus on building robust applications without worrying about registry management.
