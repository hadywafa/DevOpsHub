# EC2 (Elastic Compute Cloud)

Amazon EC2 (Elastic Compute Cloud) is a core service that allows users to launch and manage virtual servers, known as instances, in the cloud. EC2 provides resizable compute capacity, enabling users to scale their infrastructure up or down based on demand.

## `Instances`

- instances have a lifecycle that includes launching, running, stopping, and terminating.   Users can start, stop, and terminate instances as needed to manage compute capacity and costs.

- Users should be aware of the pricing implications associated with different instance types and usage patterns.
- EC2 instances can be used for a wide range of applications, including web hosting, development and testing, data processing, and high-performance computing.

**Launch Instance:**  

- An AMI is a template that contains the software configuration (operating system, application server, and applications) required to launch your instance.
- each AIM has its unique id

- **Instance Types:**  
  - EC2 instances come in various types optimized for different use cases, such as general-purpose, compute-optimized, memory-optimized, and storage-optimized instances. Each instance type offers different combinations of CPU, memory, storage, and networking resources to meet specific application requirements.

- **Key pair (login)**
  - You can use a key pair to securely connect to your instance remotely.
  - file formate types
        - openssh: to connect with Lunik terminal.
        - to connect with putty app.

- **Network settings**
  - security group is a firewall that we use to allow or deny for any external machines that tries to connect to that instance.

- **Configure storage**

## Launch Instance

- `AMI`: is a template that contains the software configuration (operating system, application server, and applications) required to launch your instance.

- `Security Groups` : A security group is a set of firewall rules that control the traffic for your instance. Add rules to allow specific traffic to reach your instance.

### Steps to Connect to a Remote Server Using OpenSSH

1. **Install OpenSSH**:
   Ensure OpenSSH is installed on your system.

   ```sh
   sudo apt update
   sudo apt install openssh-client openssh-server
   ```

2. **Obtain SSH Key**:
   Ensure you have your SSH private key file (`my-first-web-server-ssh-key.pem`).

3. **Set Correct Permissions**:
   Set the permissions of your SSH key to be readable only by you.

   ```sh
   chmod 400 /path/to/my-first-web-server-ssh-key.pem
   ```

4. **Find Public DNS or IP Address**:
   Obtain the Public DNS or IP address of the remote server from your hosting provider or AWS Management Console.

5. **Connect to the Remote Server**:
   Use the `ssh` command to connect to the server. Replace `/path/to/my-first-web-server-ssh-key.pem` with your key file path and `user@server-ip` with your server's user and IP address.

   ```sh
   ssh -i /path/to/my-first-web-server-ssh-key.pem user@server-ip
   ```

   **Example**:

   ```sh
   ssh -i /mnt/c/Users/HadyW/Desktop/AWS/my-first-web-server-ssh-key.pem ubuntu@51.20.193.97
   ```

## `Images`

- **Amazon Machine Images (AMIs):** EC2 images, also known as AMIs, are pre-configured templates that contain the operating system, applications, libraries, and configurations required to launch EC2 instances. Users can create custom AMIs or use publicly available ones provided by AWS and the community.
- **Creating Custom AMIs:** Users can create custom AMIs from existing EC2 instances or import virtual machine images from on-premises environments. Custom AMIs allow users to standardize configurations and quickly deploy new instances with predefined settings.
- **Sharing AMIs:** Users can share custom AMIs with other AWS accounts or publicly publish them in the AWS Marketplace for others to use.
- **Notes:**
  - Regularly updating and patching AMIs is essential for maintaining security and compliance.
  - AMIs can be versioned to track changes and updates over time.

## `EBS (Elastic Block Store)`

- **Storage Volumes:** Amazon EBS (Elastic Block Store) provides block-level storage volumes that can be attached to EC2 instances. EBS volumes offer durability and low-latency performance, making them suitable for storing data that requires persistent storage.
- **Types of EBS Volumes:** EBS offers several types of volumes optimized for different use cases, including General Purpose SSD (gp2), Provisioned IOPS SSD (io1), Throughput Optimized HDD (st1), and Cold HDD (sc1).
- **Attaching and Detaching Volumes:** Users can attach EBS volumes to EC2 instances to provide additional storage capacity. Volumes can be detached and reattached to different instances as needed.
- **Snapshots:** EBS volumes can be backed up using snapshots, which are point-in-time copies of volumes stored in Amazon S3. Snapshots can be used to create new volumes, restore data, and migrate volumes between regions.
- **Notes:**
  - Properly sizing and provisioning EBS volumes is important for optimizing performance and cost.
  - Users should implement backup and disaster recovery strategies using EBS snapshots to protect against data loss.

## `Network and Security`

- **Virtual Private Cloud (VPC):** EC2 instances are deployed within Virtual Private Clouds (VPCs), which allow users to define their own network configurations, including subnets, route tables, and security groups.
- **Security Groups:** Security groups act as virtual firewalls, controlling inbound and outbound traffic to instances based on user-defined rules. Users can specify allowed protocols, ports, and IP addresses to restrict access to instances.
- **Network Interfaces:** EC2 instances can have one or more network interfaces attached, allowing them to communicate with other instances and services within the same VPC or across different VPCs.
- **Public and Private IP Addresses:** EC2 instances can be assigned both public and private IP addresses for communication over the internet and within the VPC, respectively.
- **Notes:**
  - Properly configuring security groups and network settings is crucial for securing EC2 instances and preventing unauthorized access.
  - Users should regularly review and update network configurations to maintain compliance with security best practices.

## `Load Balancing`

- **Elastic Load Balancing (ELB):** AWS offers load balancing services, such as Elastic Load Balancing (ELB), to distribute incoming traffic across multiple EC2 instances for improved availability and fault tolerance.
- **Types of Load Balancers:** ELB offers several types of load balancers, including Classic Load Balancer, Application Load Balancer (ALB), and Network Load Balancer (NLB), each designed for specific use cases and traffic patterns.
- **Health Checks:** ELB performs health checks on EC2 instances to ensure they are responsive and available to handle incoming requests. Unhealthy instances are automatically removed from the load balancer's rotation.
- **Auto Scaling Integration:** ELB integrates with Auto Scaling to automatically scale EC2 instances up or down based on traffic load and health status.
- **Notes:**
  - Load balancers help improve application availability, scalability, and fault tolerance by distributing traffic evenly across multiple instances.
  - Users should monitor load balancer metrics and configure alarms to detect and respond to changes in traffic patterns.
