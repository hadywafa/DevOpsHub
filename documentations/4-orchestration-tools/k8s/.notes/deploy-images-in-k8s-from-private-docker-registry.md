# How to Deploy an Image in Kubernetes from a Private Docker Repository

To deploy an image from a private Docker repository in Kubernetes, follow these key steps:

1. **Create a Docker Registry Secret**: Store your Docker registry credentials in a Kubernetes secret.
2. **Reference the Secret in Your Pod Specification**: Use the secret in your Kubernetes deployment or pod definition to pull the image.

## Methods to Create a Docker Registry Secret

### Method 1: Using `kubectl create secret account docker-registry`

This method is ideal for quickly creating a secret for a single Docker registry.

**Command**:

```sh
kubectl create secret docker-registry <secret-name> \
  --docker-server=https://index.docker.io/v1/ \ 
  --docker-username=<username> \
  --docker-password=<access-token> \
  --docker-email=<email>
```

**Example for AWS ECR**:

```sh
kubectl create secret docker-registry myawsecrsecret \
  --docker-server=123456789012.dkr.ecr.us-west-2.amazonaws.com \
  --docker-username=AWS \
  --docker-password=$(aws ecr get-login-password --region us-west-2) \
  --docker-email=myemail@example.com
```

**Example for Docker Hub**:

```sh
kubectl create secret docker-registry mydockerhubsecret \
  --docker-server=https://index.docker.io/v1/ \
  --docker-username=mydockerhubusername \
  --docker-password=mydockerhubpassword \
```

### Method 2: Using a YAML Manifest

This method is suitable for managing multiple Account Docker registries and is ideal for declarative configurations.

**Steps**:

1. **Generate the Docker config file**:

   ```sh
   aws ecr get-login-password --region us-west-2 | docker login --username AWS --password-stdin 123456789012.dkr.ecr.us-west-2.amazonaws.com
   ```

2. **Base64 encode the Docker config file**:

   ```sh
   cat ~/.docker/config.json | base64
   ```

3. **Create the YAML Manifest**:

   ```yaml
   apiVersion: v1
   kind: Secret
   metadata:
     name: myawsecrsecret
   data:
     .dockerconfigjson: eyJhdXRocyI6IHsiMTIzNDU2Nzg5MDEyLmRrci5lY3IudXMtd2VzdC0yLmFtYXpvbmF3cy5jb20iOiB7InVzZXJuYW1lIjogIkFXUyIsICJwYXNzd29yZCI6ICJhYmNkZWYifX19
   type: kubernetes.io/dockerconfigjson
   ```

4. **Apply the YAML Manifest**:

   ```sh
   kubectl apply -f myawsecrsecret.yaml
   ```

### Method 3: Using AWS CLI and Kubernetes Service Account

This method is suitable for environments requiring dynamic credential management and secure access to multiple registries.

**Steps**:

1. **Create an IAM Role with ECR Access**:

   ```json
   {
     "Version": "2012-10-17",
     "Statement": [
       {
         "Effect": "Allow",
         "Action": ["ecr:GetDownloadUrlForLayer", "ecr:BatchGetImage", "ecr:BatchCheckLayerAvailability"],
         "Resource": "*"
       }
     ]
   }
   ```

2. **Associate the IAM Role with a Kubernetes Service Account**:

   ```yaml
   apiVersion: v1
   kind: ServiceAccount
   metadata:
     name: ecr-access
     annotations:
       eks.amazonaws.com/role-arn: arn:aws:iam::123456789012:role/ECRAccessRole
   ```

3. **Configure the Kubernetes Deployment to Use the Service Account**:

   ```yaml
   apiVersion: apps/v1
   kind: Deployment
   metadata:
     name: myapp-deployment
   spec:
     replicas: 1
     selector:
       matchLabels:
         app: myapp
     template:
       metadata:
         labels:
           app: myapp
       spec:
         serviceAccountName: ecr-access
         containers:
           - name: myapp
             image: 123456789012.dkr.ecr.us-west-2.amazonaws.com/myapp:latest
             ports:
               - containerPort: 80
   ```

## Deploy the Application

Once you have created the Docker registry secret using one of the methods above, reference the secret in your pod or deployment specification and apply the configuration.

**Example Deployment YAML**:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp-deployment
spec:
  replicas: 1
  selector:
    matchLabels:
      app: myapp
  template:
    metadata:
      labels:
        app: myapp
    spec:
      containers:
        - name: myapp
          image: 123456789012.dkr.ecr.us-west-2.amazonaws.com/myapp:latest
          ports:
            - containerPort: 80
      imagePullSecrets:
        - name: myawsecrsecret
```

**Apply the Deployment**:

```sh
kubectl apply -f deployment.yaml
```

## Summary

1. **Create a Docker registry secret** using one of the methods:

   - `kubectl create secret docker-registry` for single registry.
   - YAML manifest for multiple registries or declarative configurations.
   - AWS CLI and Kubernetes service account for dynamic credential management.

2. **Reference the secret** in your pod or deployment specification under `imagePullSecrets`.

3. **Deploy your application** using `kubectl apply`.
