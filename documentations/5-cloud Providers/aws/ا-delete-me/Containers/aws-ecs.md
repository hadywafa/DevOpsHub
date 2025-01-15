# Amazon Elastic Container Service (Amazon ECS)

![alt text](images/aws-orchestration-tools.png)

## Types of ECS

### **ECS with EC2 Launch Type**

- **Managed by You**:
  - **EC2 Instances**: You need to provision, configure, and manage the EC2 instances that form the ECS cluster. This includes:
    - Selecting instance types.
    - Managing instance lifecycle (starting, stopping, terminating).
    - Patching and updating the instances.
    - Monitoring and scaling the instances.
  - **Networking**: Configuring VPC, subnets, security groups, and network interfaces.
  - **Task and Service Definitions**: Defining how your containerized applications run, including specifying Docker images, CPU/memory allocation, networking, and IAM roles.
- **Managed by AWS**:
  - **ECS Control Plane**: The orchestration and management of containers, scheduling tasks, and maintaining desired state.

### **ECS with Fargate Launch Type**

- **Managed by You**:
  - **Task and Service Definitions**: Similar to EC2 launch type, you need to define how your containers run.
  - **Networking**: Configuring VPC, subnets, and security groups for your tasks.
- **Managed by AWS**:
  - **Infrastructure Management**: AWS handles provisioning, scaling, and managing the underlying infrastructure.
  - **ECS Control Plane**: Same as above, AWS manages the orchestration and scheduling.

## Setup Requirements

### **ECS with EC2**

- **Create an ECS Cluster**: Define your cluster in the ECS console.
- **Provision EC2 Instances**: Launch EC2 instances with the ECS-optimized AMI or install the ECS agent on your custom AMIs.
- **Configure Networking**: Set up VPC, subnets, security groups, and IAM roles.
- **Define Task Definitions**: Specify Docker images, resource requirements, and network settings.
- **Create Services**: Set up ECS services to manage the lifecycle and scaling of your tasks.
- **Setup Auto Scaling (optional)**: Configure ECS service auto scaling and EC2 auto scaling groups.

### **ECS with Fargate**

- **Create an ECS Cluster**: Same as with EC2.
- **Define Task Definitions**: Specify Docker images, resource requirements, and network settings.
- **Create Services**: Set up ECS services for Fargate tasks.
- **Configure Networking**: Set up VPC, subnets, security groups, and IAM roles.

## Cost Considerations

- **ECS with EC2**: Costs associated with EC2 instances, storage, and networking.
- **ECS with Fargate**: Pay for vCPU and memory resources consumed by your tasks. Fargate pricing is generally higher per unit of compute compared to EC2 but removes the overhead of managing instances.

## When to Use

- You prefer a simpler container orchestration service.
- You want tight integration with AWS services.
- You need a serverless option like Fargate to reduce infrastructure management.
- Your workloads are already heavily dependent on other AWS services.
