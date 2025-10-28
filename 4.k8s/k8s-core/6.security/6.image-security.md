# Image Security

Accessing container images stored in private repositories, such as Docker Hub or AWS Elastic Container Registry (ECR), is a common requirement in Kubernetes (K8s) deployments. Securing access to these private registries ensures that only authorized users and services can pull and deploy your container images. In this guide, we'll walk through how to configure Kubernetes to access private repositories on Docker Hub and AWS ECR, complete with step-by-step instructions and examples.

## Table of Contents

1. [Accessing Private Docker Hub Repositories in Kubernetes](#1-accessing-private-docker-hub-repositories-in-kubernetes)
   - 1.1. **Creating a Kubernetes Secret for Docker Hub**
   - 1.2. **Using the Secret in Pod Specifications**
   - 1.3. **Using ImagePullSecrets with Service Accounts**
2. [Accessing Private AWS ECR Repositories in Kubernetes](#2-accessing-private-aws-ecr-repositories-in-kubernetes)
   - 2.1. **Prerequisites**
   - 2.2. **Creating an ECR Repository**
   - 2.3. **Configuring AWS IAM Roles**
   - 2.4. **Creating a Kubernetes Secret for ECR**
   - 2.5. **Using the Secret in Pod Specifications**
3. [Best Practices](#3-best-practices)
4. [Conclusion](#4-conclusion)

## 1. Accessing Private Docker Hub Repositories in Kubernetes

To pull images from a private Docker Hub repository, Kubernetes needs credentials to authenticate with Docker Hub. This is achieved by creating a Kubernetes Secret of type `docker-registry` and referencing it in your Pod specifications.

### 1.1. Creating a Kubernetes Secret for Docker Hub

You can create a Kubernetes Secret manually using the `kubectl` command or define it in a YAML manifest.

**Using `kubectl` Command:**

```bash
kubectl create secret docker-registry dockerhub-secret \
  --docker-server=https://index.docker.io/v1/ \
  --docker-username=YOUR_DOCKERHUB_USERNAME \
  --docker-password=YOUR_DOCKERHUB_PASSWORD \
  --docker-email=YOUR_EMAIL
```

**Using a YAML Manifest:**

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: dockerhub-secret
  namespace: your-namespace
data:
  .dockerconfigjson: <base64-encoded-docker-config>
type: kubernetes.io/dockerconfigjson
```

To create the secret using a YAML file:

1. Create a `.dockerconfigjson` file by encoding your Docker credentials:

   ```bash
   cat <<EOF > .dockerconfigjson
   {
     "auths": {
       "https://index.docker.io/v1/": {
         "username": "YOUR_DOCKERHUB_USERNAME",
         "password": "YOUR_DOCKERHUB_PASSWORD",
         "email": "YOUR_EMAIL",
         "auth": "$(echo -n 'YOUR_DOCKERHUB_USERNAME:YOUR_DOCKERHUB_PASSWORD' | base64)"
       }
     }
   }
   EOF
   ```

2. Base64 encode the `.dockerconfigjson` content:

   ```bash
   kubectl create secret generic dockerhub-secret \
     --from-file=.dockerconfigjson=.dockerconfigjson \
     --type=kubernetes.io/dockerconfigjson \
     --namespace=your-namespace
   ```

### 1.2. Using the Secret in Pod Specifications

Reference the created secret in your Pod or Deployment YAML to allow Kubernetes to use it when pulling the image.

**Example Deployment YAML:**

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: private-dockerhub-deployment
  namespace: your-namespace
spec:
  replicas: 1
  selector:
    matchLabels:
      app: private-dockerhub-app
  template:
    metadata:
      labels:
        app: private-dockerhub-app
    spec:
      containers:
        - name: app-container
          image: your-dockerhub-username/your-private-repo:tag
          ports:
            - containerPort: 80
      imagePullSecrets:
        - name: dockerhub-secret
```

### 1.3. Using ImagePullSecrets with Service Accounts

For better scalability and management, you can associate `imagePullSecrets` with a Kubernetes Service Account. This way, all Pods using that Service Account will automatically use the specified secrets.

**Create a Service Account:**

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: dockerhub-serviceaccount
  namespace: your-namespace
imagePullSecrets:
  - name: dockerhub-secret
```

**Reference the Service Account in Your Deployment:**

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: private-dockerhub-deployment
  namespace: your-namespace
spec:
  replicas: 1
  selector:
    matchLabels:
      app: private-dockerhub-app
  template:
    metadata:
      labels:
        app: private-dockerhub-app
    spec:
      serviceAccountName: dockerhub-serviceaccount
      containers:
        - name: app-container
          image: your-dockerhub-username/your-private-repo:tag
          ports:
            - containerPort: 80
```

## 2. Accessing Private AWS ECR Repositories in Kubernetes

AWS ECR is a fully managed Docker container registry that makes it easy to store, manage, and deploy Docker container images. To access private ECR repositories from Kubernetes, you need to authenticate Kubernetes with ECR.

### 2.1. Prerequisites

- **AWS CLI Installed:** Ensure that the AWS CLI is installed and configured with the necessary permissions.
- **kubectl Configured:** Your Kubernetes cluster should be accessible via `kubectl`.
- **IAM Permissions:** The IAM role or user used must have permissions to access ECR.

### 2.2. Creating an ECR Repository

If you haven't already, create an ECR repository to store your images.

```bash
aws ecr create-repository --repository-name your-ecr-repo --region your-region
```

### 2.3. Configuring AWS IAM Roles

For Kubernetes to access ECR securely, especially if you're using Amazon EKS, it's recommended to use IAM Roles for Service Accounts (IRSA). This allows your Kubernetes Pods to assume IAM roles with specific permissions.

**Steps for IRSA (Amazon EKS Specific):**

1. **Create an IAM Policy for ECR Access:**

   ```json
   {
     "Version": "2012-10-17",
     "Statement": [
       {
         "Effect": "Allow",
         "Action": ["ecr:GetDownloadUrlForLayer", "ecr:BatchGetImage", "ecr:BatchCheckLayerAvailability"],
         "Resource": "arn:aws:ecr:your-region:your-account-id:repository/your-ecr-repo"
       },
       {
         "Effect": "Allow",
         "Action": "ecr:GetAuthorizationToken",
         "Resource": "*"
       }
     ]
   }
   ```

   Save this policy as `ecr-access-policy.json` and create it:

   ```bash
   aws iam create-policy \
     --policy-name ECRAccessPolicy \
     --policy-document file://ecr-access-policy.json
   ```

2. **Create an IAM Role for the Service Account:**

   ```bash
   eksctl create iamserviceaccount \
     --name ecr-serviceaccount \
     --namespace your-namespace \
     --cluster your-cluster-name \
     --attach-policy-arn arn:aws:iam::your-account-id:policy/ECRAccessPolicy \
     --approve \
     --override-existing-serviceaccounts
   ```

   This command creates a Kubernetes Service Account named `ecr-serviceaccount` with the necessary IAM permissions.

### 2.4. Creating a Kubernetes Secret for ECR (Alternative Method)

If you're not using EKS or IRSA, you can create a Kubernetes Secret manually using the ECR authentication token.

1. **Retrieve the ECR Authentication Token:**

   ```bash
   aws ecr get-login-password --region your-region
   ```

2. **Create the Kubernetes Secret:**

   ```bash
   kubectl create secret docker-registry ecr-secret \
     --docker-server=your-aws-account-id.dkr.ecr.your-region.amazonaws.com \
     --docker-username=AWS \
     --docker-password=$(aws ecr get-login-password --region your-region) \
     --docker-email=your-email@example.com \
     --namespace=your-namespace
   ```

### 2.5. Using the Secret in Pod Specifications

Reference the created secret in your Pod or Deployment YAML to allow Kubernetes to use it when pulling the image.

**Example Deployment YAML Using IRSA:**

If you're using IRSA, ensure your Service Account is correctly referenced.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: private-ecr-deployment
  namespace: your-namespace
spec:
  replicas: 1
  selector:
    matchLabels:
      app: private-ecr-app
  template:
    metadata:
      labels:
        app: private-ecr-app
    spec:
      serviceAccountName: ecr-serviceaccount
      containers:
        - name: app-container
          image: your-aws-account-id.dkr.ecr.your-region.amazonaws.com/your-ecr-repo:tag
          ports:
            - containerPort: 80
```

**Example Deployment YAML Using `imagePullSecrets`:**

If you're using a Kubernetes Secret (`ecr-secret`), reference it directly.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: private-ecr-deployment
  namespace: your-namespace
spec:
  replicas: 1
  selector:
    matchLabels:
      app: private-ecr-app
  template:
    metadata:
      labels:
        app: private-ecr-app
    spec:
      containers:
        - name: app-container
          image: your-aws-account-id.dkr.ecr.your-region.amazonaws.com/your-ecr-repo:tag
          ports:
            - containerPort: 80
      imagePullSecrets:
        - name: ecr-secret
```

## 3. Best Practices

1. **Use Least Privilege:** Only grant the minimal necessary permissions to access container registries. For AWS ECR, restrict IAM policies to specific repositories.

2. **Rotate Credentials Regularly:** Regularly update and rotate credentials and secrets to minimize the risk of compromised access.

3. **Leverage Kubernetes Namespaces:** Isolate secrets and access within Kubernetes namespaces to limit the blast radius in case of a security breach.

4. **Automate Secret Management:** Use tools like [Sealed Secrets](https://github.com/bitnami-labs/sealed-secrets) or [HashiCorp Vault](https://www.vaultproject.io/) for managing secrets securely.

5. **Monitor and Audit Access:** Implement logging and monitoring to track access to private registries and detect any unauthorized attempts.

## 4. Conclusion

Accessing private container registries like Docker Hub and AWS ECR from Kubernetes requires careful handling of authentication credentials to ensure secure and seamless deployments. By creating Kubernetes Secrets of type `docker-registry` and properly referencing them in your Pod specifications, you can securely pull images from private repositories. Additionally, leveraging IAM roles and policies, especially with Amazon EKS and IRSA, enhances security by providing fine-grained access control.

Implementing these configurations not only safeguards your container images but also aligns with best practices for Kubernetes security. Whether you're using Docker Hub, AWS ECR, or another private registry, the principles outlined here will help you maintain a secure and efficient Kubernetes environment.
