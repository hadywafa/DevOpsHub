# Networking Questions

## What is Load Balancer

### Load Balancer Overview

- **External Service**: The load balancer is an external service managed by your cloud provider (such as AWS, GCP, Azure, etc.).
- **Public IP Address**: This service has a public IP address that is used to expose your application to the internet.

### How It Works

1. **Public Access**: External users access your application using the public IP address of the load balancer.
2. **Traffic Management**: The load balancer receives incoming traffic and then forwards it to one of the nodes in your Kubernetes cluster.
3. **Node Awareness**: The load balancer is aware of all the nodes in your Kubernetes cluster that are running the service.
4. **Traffic Forwarding**: Based on specific criteria (like round-robin, least connections, etc.), the load balancer forwards traffic to the appropriate node's NodePort.
5. **Internal Routing**: Once the traffic reaches the node, `kube-proxy` routes it to the appropriate pod based on the service's ClusterIP or other routing rules.

### Example Scenario

1. **Create a LoadBalancer Service**

   ```yaml
   apiVersion: v1
   kind: Service
   metadata:
     name: my-loadbalancer-service
   spec:
     type: LoadBalancer
     selector:
       app: my-app
     ports:
       - protocol: TCP
         port: 80 # External Port
         targetPort: 80 # Pod Port
   ```

2. **Provisioning**

   - Kubernetes requests the cloud provider to create a load balancer.
   - The cloud provider provisions a load balancer and assigns a public IP address.

3. **Accessing the Service**

   - Users access the application using the load balancer's public IP, e.g., `http://<EXTERNAL-IP>:80`.
   - The load balancer receives the traffic and forwards it to one of the cluster nodes on the specified NodePort.

4. **Traffic Routing**

   - The traffic is directed to the appropriate pod by the node’s `kube-proxy` based on the service's ClusterIP.

### Load Balancer Types and Criteria

- **Round Robin**: Distributes traffic evenly across all nodes.
- **Least Connections**: Sends traffic to the node with the fewest active connections.
- **IP Hash**: Directs traffic based on a hash of the client's IP address, ensuring that requests from the same client are consistently directed to the same node.

### Diagram

Here's a visual representation to help understand the process:

```ini
               +---------------------------+
               |   Cloud Provider's Load   |
               |          Balancer         |
               +-----------+---------------+
                           |
                +----------+----------+
                | Public IP: 198.51.100.1 |
                +----------+----------+
                           |
           +---------------+---------------+
           |               |               |
+----------+-----+ +-------+------+ +------++-------+
| Kubernetes Node | | Kubernetes Node | | Kubernetes Node |
|     Node 1      | |     Node 2      | |     Node 3      |
+-----------------+ +-----------------+ +-----------------+
         |                  |                  |
   +-----+-----+      +-----+-----+      +-----+-----+
   |    Pod    |      |    Pod    |      |    Pod    |
   +-----------+      +-----------+      +-----------+
```

### Summary

- **Load Balancer**: External service with a public IP address.
- **Traffic Management**: Forwards traffic to Kubernetes nodes.
- **Node Awareness**: Knows about all nodes running the service.
- **Internal Routing**: Nodes route traffic to the appropriate pods.

By using a LoadBalancer service, you can easily expose your Kubernetes applications to the internet with a public IP address managed by your cloud provider. This setup ensures that your application can handle incoming traffic efficiently and distribute the load across multiple nodes and pods.

## Using AWS Load Balancer with a Self-Managed Kubernetes Cluster ?

### AWS Load Balancer and Kubernetes

When you are using Kubernetes on AWS (whether you are using EKS or self-managed Kubernetes on EC2 instances), you can leverage AWS Load Balancer to expose your services to the outside world. Kubernetes natively supports integration with AWS Load Balancers through the LoadBalancer service type.

### Types of Load Balancers in AWS

1. Classic Load Balancer (CLB)
1. Network Load Balancer (NLB)
1. Application Load Balancer (ALB)

Kubernetes typically uses NLBs or ALBs for exposing services.

### Prerequisites

- Your Kubernetes cluster is set up on AWS EC2 instances.
- You have kubectl configured to interact with your Kubernetes cluster.
- AWS CLI installed and configured.

### Steps to Set Up an AWS Load Balancer with Kubernetes

1. **Install and Configure the AWS Load Balancer Controller**

   The AWS Load Balancer Controller is a controller to help manage Elastic Load Balancers for a Kubernetes cluster.

   **Step 1:** Add the IAM policy to your worker nodes:

   ```sh
   aws iam create-policy \
   --policy-name AWSLoadBalancerControllerIAMPolicy \
   --policy-document file://iam_policy.json
   ```

   Download the IAM policy from the AWS documentation for the AWS Load Balancer Controller.

   **Step 2:** Associate this policy with an IAM role and attach it to your worker nodes.

   **Step 3:** Deploy the AWS Load Balancer Controller:

   ```sh
   kubectl apply -k "github.com/aws/eks-charts/stable/aws-load-balancer-controller//crds?ref=master"
   kubectl apply -f https://github.com/aws/eks-charts/raw/master/stable/aws-load-balancer-controller/deploy/v2.1.3/deployment.yaml
   ```

2. **Create a Deployment and Service in Kubernetes**

   **Deployment.yaml:**

   ```yaml
   apiVersion: apps/v1
   kind: Deployment
   metadata:
     name: my-app
   spec:
     replicas: 3
     selector:
       matchLabels:
         app: my-app
     template:
       metadata:
         labels:
           app: my-app
       spec:
         containers:
           - name: my-app
             image: my-app-image:latest
             ports:
               - containerPort: 80
   ```

   **Service.yaml:**

   ```yaml
   apiVersion: v1
   kind: Service
   metadata:
     name: my-app-service
     annotations:
       service.beta.kubernetes.io/aws-load-balancer-type: nlb
   spec:
     selector:
       app: my-app
     ports:
       - protocol: TCP
         port: 80
         targetPort: 80
     type: LoadBalancer
   ```

3. **Deploy the Service**

   ```sh
   kubectl apply -f deployment.yaml
   kubectl apply -f service.yaml
   ```

4. **Verify the Load Balancer**

   After deploying, you can check the service to get the external IP of the load balancer:

   ```sh
   kubectl get services my-app-service
   ```

   You should see an external IP address (or hostname) assigned to your service.

5. **Access Your Service**

   Use the external IP (or hostname) provided by AWS Load Balancer to access your service:

   ```sh
   curl <EXTERNAL-IP>
   ```

### Detailed Explanation of AWS Load Balancer Types in Kubernetes

1. **Classic Load Balancer (CLB):**

   - **Usage:** Basic load balancing across multiple EC2 instances.
   - **Example Annotation:**

     ```yaml
     service.beta.kubernetes.io/aws-load-balancer-backend-protocol: "http"
     service.beta.kubernetes.io/aws-load-balancer-ssl-cert: "<your-cert-arn>"
     service.beta.kubernetes.io/aws-load-balancer-ssl-ports: "443"
     ```

2. **Network Load Balancer (NLB):**

   - **Usage:** For high-performance TCP/UDP load balancing, ideal for latency-sensitive applications.
   - **Example Annotation:**

     ```yaml
     service.beta.kubernetes.io/aws-load-balancer-type: "nlb"
     ```

3. **Application Load Balancer (ALB):**

   - **Usage:** For HTTP/HTTPS traffic, providing advanced routing features.
   - **Example Annotation:**

     ```yaml
     apiVersion: extensions/v1beta1
     kind: Ingress
     metadata:
       name: my-ingress
       annotations:
         kubernetes.io/ingress.class: "alb"
         alb.ingress.kubernetes.io/scheme: internet-facing
     spec:
       rules:
         - http:
             paths:
               - path: /*
                 backend:
                   serviceName: my-service
                   servicePort: 80
     ```

### Summary

- **ClusterIP:** Internal communication within the cluster. Service is only accessible from within the cluster.
- **NodePort:** Exposes the service on each node's IP at a static port. Can be accessed externally via `<NodeIP>:<NodePort>`.
- **LoadBalancer:** Creates an external load balancer (such
