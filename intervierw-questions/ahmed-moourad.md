# DevOps Interview Questions for Juniors

<p align="center">
<img width="600" src="https://github.com/Ahmed-Moourad/DevOps-Interview-Questions-for-Juniors/assets/112473376/c2adb7f2-3245-4654-bb88-0b7102f2ce55" alt="DevOps Q&A">
</p>

> DevOps Interview Questions and Answers for Junior DevOps Engineers

**Disclaimer:**

📝 You are welcome to edit and add Questions/answers through Pull Request: read about contribution guidelines [How To Contribute](How-to-contribute.md)

- These questions are for the Junior/beginner in the DevOps field
- These questions are not for specific companies/entities, they cover the most popular DevOps tools, and these tools may vary from one company to another based on the technology stack used by it .. so you need to check the job requirements for the position you are applying and focus on what is there.

<h3 align="left">Included Tools:</h3>
<p align="left"> <a href="https://github.com/Ahmed-Moourad/DevOps-Interview-Questions-for-Juniors?tab=readme-ov-file#aws-questions" target="_blank" rel="noreferrer"> <img src="https://raw.githubusercontent.com/devicons/devicon/master/icons/amazonwebservices/amazonwebservices-original-wordmark.svg" alt="aws" width="40" height="40"/> </a> <a href="https://github.com/Ahmed-Moourad/DevOps-Interview-Questions-for-Juniors?tab=readme-ov-file#docker-questions" target="_blank" rel="noreferrer"> <img src="https://raw.githubusercontent.com/devicons/devicon/master/icons/docker/docker-original-wordmark.svg" alt="docker" width="40" height="40"/> </a> <a href="https://github.com/Ahmed-Moourad/DevOps-Interview-Questions-for-Juniors?tab=readme-ov-file#linux-questions" target="_blank" rel="noreferrer"> <img src="https://raw.githubusercontent.com/devicons/devicon/master/icons/linux/linux-original.svg" alt="linux" width="40" height="40"/> </a> <a href="https://github.com/Ahmed-Moourad/DevOps-Interview-Questions-for-Juniors?tab=readme-ov-file#general-questions" target="_blank" rel="noreferrer"> <img src="https://www.vectorlogo.zone/logos/gnu_bash/gnu_bash-icon.svg" alt="bash" width="40" height="40"/> </a> <a href="https://github.com/Ahmed-Moourad/DevOps-Interview-Questions-for-Juniors?tab=readme-ov-file#kubernetes-questions" target="_blank" rel="noreferrer"> <img src="https://www.vectorlogo.zone/logos/kubernetes/kubernetes-icon.svg" alt="kubernetes" width="40" height="40"/> </a> <a href="https://github.com/Ahmed-Moourad/DevOps-Interview-Questions-for-Juniors?tab=readme-ov-file#general-questions" target="_blank" rel="noreferrer"> <img src="https://www.vectorlogo.zone/logos/git-scm/git-scm-icon.svg" alt="git" width="40" height="40"/> </a> <a href="https://github.com/Ahmed-Moourad/DevOps-Interview-Questions-for-Juniors?tab=readme-ov-file#general-questions" target="_blank" rel="noreferrer"> <img src="https://www.vectorlogo.zone/logos/jenkins/jenkins-icon.svg" alt="jenkins" width="40" height="40"/> </a> Terraform,</a> Ansible, </a> and more coming ...

## AWS Questions:

<details><summary>
1. What’s EC2 Instance types?</summary><br><b>

    - General-Purpose Instances
    - Memory-Optimized Instances
    - Compute-Optimized Instances
    - Storage Optimized Instances

![image](https://github.com/Ahmed-Moourad/DevOps-Interview-Questions-for-Juniors/assets/112473376/f1cd6e00-8218-4d26-9f0e-066be57576e8)
</b></details>

---

<details><summary>
 2. What’s VPC?</summary><br><b>

A VPC is a virtual network that closely resembles a traditional network that you'd operate in your own data center.
</b></details>

---

<details><summary>
3. What’s S3 bucket and what types of it?</summary><br><b>

Amazon S3 is an object storage service that stores data as objects within buckets. An object is a file and any metadata that describes the file. A bucket is a container for objects.

    Types(storage classes):
    - S3 Standard: for frequently accessed data
    - S3 Intelligent-Tiering: for automatic cost savings for data with unknown or changing access patterns
    - S3 Standard-Infrequent Access (S3 Standard-IA) and S3 One Zone-Infrequent Access (S3 One Zone-IA) for less frequently accessed data,
    - S3 Glacier

</b></details>

---

<details><summary>
4. Is there a difference between SG and NACL?</summary><br><b>

Security groups are associated with an instance of a service. It can be associated with one or more security groups that have been created by the user. (Stateful)
A security group can be understood as a firewall to protect EC2 instances.
NACL can be understood as the firewall or protection for the subnet. (stateless)
</b></details>

---

<details><summary>
5. What’s the difference between Public Subnet and Private Subnet?</summary><br><b>

The instances in the public subnet can send outbound traffic directly to the internet.(Via Internet Gatway).
Whereas the instances in the private subnet can't. Instead, the instances in the private subnet can access the internet by using a network address translation (NAT) gateway that resides in the public subnet.
</b></details>

---

<details><summary>
6. How can an application access Internet without receiving requests from the internet?</summary><br><b>

Using NAT configured in the Routing Table.
The database servers can connect to the internet for software updates using the NAT gateway, but the internet cannot establish connections to the database servers.
</b></details>

---

<details><summary>  
7. Design Architecture for web application contains 3 tiers: Frontend, Backend, and Database?</summary><br><b>

![image](https://github.com/Ahmed-Moourad/DevOps-Interview-Questions-for-Juniors/assets/112473376/cc5d5560-885f-42a0-8a9c-371baff370ac)

</b></details>

---

<details><summary>
8. How you can cost optimize  your infrastructure?</summary><br><b>

obtaining the best pricing and terms for IT purchases, standardizing, simplifying, and rationalizing assets such as platforms and applications, as well as processes and services, automating and digitalizing both the IT and business operations. Monitor billing · Reduce manual processes

    **On AWS** :
    - stop guessing capacity (use Autoscaling Group).
    - Choose the right pricing models.
    - Use Reserved Instances (RI) to reduce RDS, Redshift, ElastiCache, and Elasticsearch costs.
    - Match Capacity with Demand.
    - Identify Amazon EC2 instances with low utilization and reduce cost by stopping or rightsizing.
    - Implement processes to identify resource waste.

</b></details>

---

<details><summary>
9. What are the types of Database engines on AWS?</summary><br><b>

    - Amazon RDS is available on several database instance types - optimized for memory, performance, or I/O – and provides you with **six familiar database engines** to choose from, including:

Amazon Aurora, PostgreSQL, MySQL, MariaDB, Oracle Database, and SQL Server. - Ledger: Amazon Quantum Ledger Database (Amazon QLDB) - Document: Amazon DocumentDB (with MongoDB compatibility) - No SQL: DynamoDB - In-memory: Amazon ElastiCache - Graph: Amazon Neptune

</b></details>

---

<details><summary>
10. What’s the difference between AWS Shield vs AWS WAF vs AWS Guard-Duty?</summary><br><b>

    **Shield** is DDoS protection and is also located "at the edge".

    **AWS WAF** focuses on Layer 7 protection(Application Layer)

Your subscription to Shield Advanced covers the basic AWS WAF fees for web ACLs, rules, and web requests.

    **GuardDuty** is intelligent threat detection. That means without much configuration, it reads your CloudTrail, Config, and VPC FlowLogs and notifies you if something unexpected happened.

    **Amazon Inspector** is more for applications. It's an automated security assessment service that helps improve the security and compliance of applications.

</b></details>

---

<details><summary>
11. What’s the difference between S3 vs EBS vs EFS?</summary><br><b>

**S3**: Object Storage
**EBS**: File System Storage (Connected to one EC2) scalable network file storage
**EFS**: scalable network file storage (Can be connected to many EC2)
</b></details>

---

<details><summary>
12. Is it possible to host an application on S3?</summary><br><b>

Only one can host a static website on Amazon S3.
by configuring your bucket for website hosting and then uploading your content to the bucket.

</b></details>

---

<details><summary>
13. What’s SSM ?</summary><br><b>

Amazon EC2 Simple Systems Manager (SSM) is a tool that allows an IT professional to automatically configure virtual servers in a cloud or in an on-premises data center. Need to install an agent.

</b></details>

---

<details><summary>
14. What is the difference between Latency Based Routing and Geo DNS in Route53?</summary><br><b>

Amazon maps out typical latency between IP addresses and AWS regions. - Choose Latency-based Routing to have the fastest response. - Geolocation maps the IP addresses to geographic locations. This permits rules like "send all users from Côte d'Ivoire to the website in France", so they see a language-specific version.

</b></details>

---

<details><summary>
15. What is RTO and RPO in AWS?</summary><br><b>

**RTO** (Recovery Time Objective): is a measure of how quickly can your application recover after an outage
**RPO** (Recovery Point Objective): is a measure of the maximum amount of data loss that your application can tolerate.
</b></details>

---

<details><summary>
16.  What are DevOps tools on AWS?</summary><br><b>

    - AWS CodePipeline: Software Release Workflows
    - AWS CodeBuild: Build and Test Code
    - AWS CodeDeploy: Deployment Automation
    - AWS CodeStar: Unified CI/CD Projects
    - AWS CodeCommit: Private Git Hosting
    - Lambda, Amazon Elastic Container Registry (ECR), Amazon Elastic Kubernetes Service (EKS)

</b></details>

## Docker Questions:

<details><summary>
17. What’s the difference between container vs VM?</summary><br><b>

![image](https://github.com/Ahmed-Moourad/DevOps-Interview-Questions-for-Juniors/assets/112473376/e5eb4f75-82d4-4b39-8ac7-e5c5a428fb0d)

**VM**: uses separate OS for each VM

**Containers**:

- Use the Host OS
- Less utilization
- Your app is backed in a container and shared between environments: DEV, TEST, OPERATION
- Less size
- Fast boot up
  containers abstract application layer, vm abstract os

</b></details>

---

<details><summary>
18. What are Docker Image layers?</summary><br><b>

Layers are a result of the way Docker images are built. Each step in a Dockerfile creates a new “layer” that’s essentially a diff of the filesystem changes since the last step.
Metadata instructions such as LABEL and MAINTAINER do not create layers because they don’t affect the filesystem.

- Each layer is a snapshot of changes made to the filesystem.
- Layers are created from instructions in a Dockerfile (like RUN, COPY, ADD).
- The final image is a stack of these layers, combined to form a complete environment.

🧪 Example Breakdown

Let’s say your Dockerfile looks like this:

```dockerfile
FROM ubuntu
RUN apt update
RUN apt install -y python3
COPY . /app
CMD ["python3", "/app/app.py"]
```

This creates layers like:

- Base layer: Ubuntu OS
- Update layer: apt update
- Install layer: Python3 installed
- Copy layer: Your app files added
- Command layer: Default command to run
  Each layer is read-only and cached, so Docker can reuse them to speed up builds.

🔄 Why Layers Matter

- 🧠 Efficiency: Docker reuses unchanged layers to avoid rebuilding everything.
- 📦 Storage: Shared layers between images save disk space.
- 🚀 Speed: Faster builds and pulls, especially in CI/CD pipelines.

</b></details>

---

<details><summary>  
19. What’s the difference between Entrypoint and CMD?</summary><br>

| Instruction  | Purpose                                           | Overridable?             |
| ------------ | ------------------------------------------------- | ------------------------ |
| `ENTRYPOINT` | Defines the **main executable** for the container | ❌ Not easily overridden |
| `CMD`        | Provides **default arguments** to ENTRYPOINT      | ✅ Easily overridden     |

🧪 Example

```Dockerfile
ENTRYPOINT ["python3"]
CMD ["app.py"]
```

- Running `docker run myimage` → executes: `python3 app.py`
- Running `docker run myimage other_script.py` → executes: `python3 other_script.py`

> So `ENTRYPOINT` locks in the command, while `CMD` sets defaults you can change at runtime.

</b></details>

---

<details><summary>
20. What are multiple base images on Dockerfile?</summary><br>

It allows you to create multiple image layers on top of the previous layers and the **AS** command provides a virtual name to the intermediate image layer. The last FROM command in the dockerfile creates the actual final image

- the idea that you have two images, the first one you build your binaries files and copy them to the second one, and the second image is the final image which from it you run your container. the first image helped you to build the second one.
- The benefits you get from this are that you built your app on a large image and the final result is a lightweight image that is on your containers.

---

It’s a way to use **multiple `FROM` instructions** in a single Dockerfile—each one starts a new build stage with its own base image. This helps you:

- **Build** your app in one stage (e.g. using `golang`)
- **Package** it in a lightweight final image (e.g. using `alpine`)
- **Copy only what you need** from one stage to another

---

🧪 Example

```Dockerfile
FROM golang:1.16 AS build
ADD /src
WORKDIR /src
RUN go test --cover -v ./...
RUN go build -v -o demo

FROM alpine:3.4
EXPOSE 8080
CMD ["demo"]
COPY --from=build /src/demo /usr/local/bin/demo
RUN chmod +x /usr/local/bin/demo
```

🔍 What’s Happening Here?

1. **Stage 1 (`build`)**:

   - Uses `golang:1.16` to compile the Go app.
   - It’s used **during the build process** to compile and test the Go app.
   - But it’s **excluded** from the final container image.
   - Runs tests and builds the binary `demo`.
   - So yes, it’s effectively “discarded”—Docker **doesn’t include the first stage** in the image that gets run.

2. **Stage 2 (final image)**:
   - Uses `alpine:3.4` for a minimal runtime.
   - Copies the compiled binary from the `build` stage.
   - Sets up the container to run `demo`.

> 💡 That’s why multi-stage builds are so useful: they let you **compile with heavy tools** and then **deploy with a clean, lightweight runtime**.

</br> </details>

---

<details><summary>
21. What are types of Docker volumes?</summary><br><b>

Docker volumes come in a few flavors, each suited to different use cases. Here's a quick breakdown to keep things simple and clear:

📦 Types of Docker Volumes

| Type                 | Description                                            | Use Case Example                             |
| -------------------- | ------------------------------------------------------ | -------------------------------------------- |
| **Named Volume**     | Managed by Docker, stored in `/var/lib/docker/volumes` | Persisting database data across restarts     |
| **Anonymous Volume** | Like named volumes but without a user-defined name     | Temporary storage for short-lived containers |
| **Bind Mount**       | Maps a specific host path into the container           | Live code editing during development         |
| **Tmpfs Mount**      | Stored in memory, not on disk                          | Sensitive data or caching during runtime     |
| **Volume Plugin**    | External storage via plugins (e.g. Amazon EBS, NFS)    | Shared storage across multiple hosts         |

### 🧪 Examples

#### Named Volume

```bash
docker volume create mydata
docker run -v mydata:/app/data myimage
```

#### Anonymous Volume

```bash
docker run -v /app/data myimage
```

#### Bind Mount

```bash
docker run -v $(pwd):/app myimage
```

#### Tmpfs Mount

```bash
docker run --tmpfs /app/cache myimage
```

#### Volume Plugin

```bash
docker volume create --driver rexray myvolume
```

> 💡 Each type has its strengths. For example, **bind mounts** are great for development, while **named volumes** shine in production.

</b></details>

---

<details><summary>
22. What are the types of Docker networks?</summary><br>

1. bridge
2. overlay
3. host
4. none
5. macvlan
6. ipvlan

---

### 🌉 1. **Bridge Network**

- **Default** for standalone containers.
- Containers get their own internal IP.
- You can expose ports using `-p` (e.g. `8080:80`).
- Great for local development and isolated setups.

---

### 🖥️ 2. **Host Network**

- Container shares the **host’s network stack**.
- No port mapping needed—container uses host IP directly.
- Useful for performance or apps needing native network access.

---

### 🚫 3. **None Network**

- No networking at all.
- Container is completely isolated.
- Ideal for sandboxed tasks or enhanced security.

---

### 🕸️ 4. **Overlay Network**

- Connects containers across **multiple Docker hosts**.
- Used in **Docker Swarm** for distributed apps.
- Enables secure multi-host communication.

---

### 🧬 5. **Macvlan Network**

- Container gets its own **MAC address** and IP on the LAN.
- Appears as a physical device on the network.
- Useful for legacy apps or network monitoring tools.

---

### 🧪 6. **IPvlan Network**

- Similar to Macvlan but uses host’s MAC address.
- Efficient for high-density environments.
- Offers fine-grained control over IP routing.

---

### 🔍 What We Mean by “Binding to Host IP”

There are **two perspectives** when we talk about containers binding to the host’s IP:

1. **Direct IP Binding (Native Networking)**  
   The container behaves like part of the host system, sharing the **host’s IP stack** without NAT or port mapping.

2. **Indirect Access via Port Publishing**  
   The container runs in isolation (e.g. on a bridge network), but we **map specific host ports to container ports**, allowing traffic through NAT.

---

### ⚖️ So What’s the Actual Difference?

| Network Type       | Directly Shares Host IP? | Port Mapping Needed?    | Container Gets Own IP? | Example Access                       |
| ------------------ | ------------------------ | ----------------------- | ---------------------- | ------------------------------------ |
| **Host**           | ✅ Yes                   | ❌ Not required         | ❌ No                  | App listens directly on host IP:port |
| **Bridge**         | ❌ No                    | ✅ Required             | ✅ Yes                 | Host IP:8080 → Container IP:80       |
| **Macvlan/IPvlan** | ✅ Yes (on LAN)          | ❌ Not required         | ✅ Yes (on network)    | Container appears as physical device |
| **Overlay**        | ❌ No                    | ✅ Possible (via Swarm) | ✅ Yes                 | Works across multiple hosts          |
| **None**           | 🚫 No Networking         | ❌ Not possible         | ❌ No IP               | Completely isolated                  |

> With `bridge`, you're forwarding ports to reach the container. With `host`, you're bypassing that—services inside the container behave as if they were installed directly on the host.

---

### 🧠 Real-Life Analogy

- **Host Network** → Like installing your app directly on the host’s OS.
- **Bridge Network** → Like placing your app in a virtual room and opening a door labeled “Port 8080” so people can come in.

So when you bind `8080:80` in bridge mode, you're **creating a port-forwarding rule**, but the container still lives on a different IP.
</br></details>

---

<details><summary>
23. What’s the difference between COPY and ADD?</summary><br>

| Feature                  | `COPY`                          | `ADD`                                        |
| ------------------------ | ------------------------------- | -------------------------------------------- |
| 📁 Basic File Copy       | ✅ Yes                          | ✅ Yes                                       |
| 🌐 Remote URL Support    | ❌ No                           | ✅ Can fetch files from URLs                 |
| 📦 Auto-Extract Archives | ❌ No                           | ✅ Automatically extracts `.tar`, `.gz`, etc |
| 🔐 Security & Clarity    | ✅ Safer and more predictable   | ⚠️ Can behave unexpectedly                   |
| 📜 Best Practice         | ✅ Preferred for most use cases | 🚫 Use only when extra features are needed   |

### 🧪 Examples

#### ✅ COPY (Recommended)

```Dockerfile
COPY ./app /usr/src/app
```

Copies local `app` folder into the image—**no surprises**.

#### ⚠️ ADD (Use with caution)

```Dockerfile
ADD https://example.com/app.tar.gz /usr/src/app/
```

Downloads and **extracts** the archive automatically.

---

### 🧠 Best Practice

> Use `COPY` for **simple, local file transfers**.  
> Use `ADD` **only** if you need to **extract archives** or **download from URLs**.

</br></details>

---

<details><summary>
24. How could you secure your Dockerfile?</summary><br>

### 🔐 1. Use Trusted Base Images (Enable Docker Content Trust (DCT))

> Content trust is disabled by default in the Docker Client. To enable it, set the DOCKER_CONTENT_TRUST environment variable to 1. This prevents users from working with tagged images unless they contain a signature.

- Prefer **official images** or those from verified publishers.
- Choose **minimal images** like `alpine` to reduce vulnerabilities.

```Dockerfile
FROM python:3.12-alpine
```

---

### 👤 2. Drop Root Privileges

- Always run your app as a **non-root user**.

```Dockerfile
RUN adduser -D appuser
USER appuser
```

---

### 🧹 3. Clean Up After Installing

- Remove caches and temp files to reduce image size and risk.

```Dockerfile
RUN apk add --no-cache curl && rm -rf /var/cache/*
```

---

### 🧼 4. Use `.dockerignore`

- Prevent sensitive or unnecessary files from being copied into the image.

```plaintext
# .dockerignore
.git
.env
node_modules
```

---

### 🧪 5. Scan for Vulnerabilities

- Use tools like **Trivy**, **Snyk**, or `docker scan` to check for known issues.

```bash
docker scan myimage
```

---

### 🧱 6. Use Multi-Stage Builds

- Separate build tools from runtime to keep the final image lean and secure.

```Dockerfile
FROM golang:1.21 AS builder
WORKDIR /app
COPY . .
RUN go build -o myapp

FROM alpine
COPY --from=builder /app/myapp /usr/local/bin/
USER nobody
CMD ["myapp"]
```

---

### 🔒 7. Pin Image Versions

- Avoid using `latest`; pin to specific versions or digests for consistency.

```Dockerfile
FROM node:20-alpine@sha256:abc123...
```

---

### 🚫 8. Avoid Secrets in Dockerfile

- Don’t hardcode credentials or tokens.
- Use environment variables or secret management tools instead.

### ©️ 9. Use COPY instead of ADD in Dockerfile

- COPY is more secure than ADD.

</br></details>

---

<details><summary>
25. What are the Stages of DevSecOps?</summary><br><b>

To adapt, software development, maintenance, and upgrading must incorporate security awareness into each stage.

    - Plan. The planning phases of DevSecOps are the least automated with the involvement of collaboration, discussion, review, and a strategy for security analysis. ...
    - Code. ...
    - Build. ...
    - Test. ...
    - Release. ...
    - Deploy. ...
    - Operation. ...
    - Monitor.

<img width="460" alt="image" src="https://github.com/Ahmed-Moourad/DevOps-Interview-Questions-for-Juniors/assets/112473376/57c095a5-d0d5-4315-9854-17fb10b08706">
  
</b></details>

## Linux Questions:

<details><summary>
26. What’s the difference between Reverse Proxy and Web Server?</summary><br>

| Component         | Role in Architecture                                      | Who It Talks To                      |
| ----------------- | --------------------------------------------------------- | ------------------------------------ |
| **Web Server**    | Serves content directly to clients (e.g. HTML, CSS, APIs) | Talks **directly to clients**        |
| **Reverse Proxy** | Sits in front of one or more web servers, routes requests | Talks to **clients and web servers** |

---

### 🧪 Example Scenario

Imagine a user visits `example.com`:

- **Web Server** (like Apache or Nginx):

  - Receives the request.
  - Responds with the website content.
  - Handles things like static files, server-side scripts, etc.

- **Reverse Proxy** (like Nginx, HAProxy, or Cloudflare):
  - Intercepts the request **before** it reaches the web server.
  - Decides which backend server to forward it to.
  - Can cache, load balance, or terminate SSL.

---

### 🔐 Why Use a Reverse Proxy?

- **Security**: Hides internal server IPs.
- **Load Balancing**: Distributes traffic across multiple servers.
- **Caching**: Speeds up repeated requests.
- **SSL Termination**: Offloads encryption work from backend servers.

<div style="text-align: left">
  <img src="https://github.com/Ahmed-Moourad/DevOps-Interview-Questions-for-Juniors/assets/112473376/bc363971-d20d-423e-9382-20d2b11ccfd0" alt="image" style="width: 40%; border-radius: 10px; margin: 0 40px" />
</div>

</br></details>

<details><summary style="color: #fc4545ff">
27. How can optimize performance for Nginx?</summary><br><b>

    **7 Tips for NGINX Performance Tuning**:
    Tip 1 – Adjust Worker Processors & Worker Connections.
    Tip 2 – Enabling Gzip Compression.
    Tip 3 – Change static content caching duration on Nginx.
    Tip 4 – Change the size of the Buffers.
    Tip 5 – Reducing Timeouts.
    Tip 6 – Disabling access logs (If required)

Tip 7 – Configure HTTP/2 Support.
</b></details>

---

<details><summary>
28. How can list all processes?</summary><br><b>

```bash
ps
ps -A
ps -e
# There is `top` also not for all
```

</b></details>

---

<details><summary>
29. How can list live processes?</summary><br><b>

```bash
ps -aux | less
```

</b></details>

---

<details><summary>
30. How could you check memory space?</summary><br><b>

```bash
cat /proc/meminfo
# `free` >>> checks memory and SWAP memory
```

</b></details>

---

<details><summary>
31. How could you check storage space?</summary><br><b>

    df -H

</b></details>

---

<details><summary>  
32. What’s file management in Linux?</summary><br><b>

    In Linux, most of the operations are performed on files. And to handle these files Linux has directories also known as folders which are maintained in a tree-like structure. Though, these directories are also a type of file themselves

</b></details>

---

<details><summary>  
33. What’s LVM and how can using it?</summary><br>

LVM, or **Logical Volume Manager**, is a powerful system in Linux that lets you manage disk storage more flexibly than traditional partitioning. Think of it as a way to **build virtual partitions** that can grow, shrink, or move—without the usual headaches.

---

### 🧠 What Is LVM?

Instead of dividing a disk into fixed partitions, LVM lets you:

- Combine multiple disks into a **single storage pool**.
- Create **logical volumes** from that pool.
- Resize volumes **on the fly**, even while the system is running.
- Take **snapshots** for backups or testing.

---

### 🧱 Key Components

| Component                | Description                           |
| ------------------------ | ------------------------------------- |
| **Physical Volume (PV)** | Raw disk or partition used as storage |
| **Volume Group (VG)**    | Pool of one or more physical volumes  |
| **Logical Volume (LV)**  | Virtual partition created from the VG |

---

### 🛠️ How to Use LVM (Basic Workflow)

1. **Create Physical Volumes**

   ```bash
   pvcreate /dev/sdb /dev/sdc
   ```

2. **Create a Volume Group**

   ```bash
   vgcreate my_vg /dev/sdb /dev/sdc
   ```

3. **Create Logical Volumes**

   ```bash
   lvcreate -L 10G -n my_lv my_vg
   ```

4. **Format and Mount**

   ```bash
   mkfs.ext4 /dev/my_vg/my_lv
   mount /dev/my_vg/my_lv /mnt
   ```

---

### 🔄 Resize Example

- **Extend volume**:

  ```bash
  lvextend -L +5G /dev/my_vg/my_lv
  resize2fs /dev/my_vg/my_lv
  ```

- **Shrink volume** (requires unmounting and caution):

  ```bash
  umount /mnt
  e2fsck -f /dev/my_vg/my_lv
  resize2fs /dev/my_vg/my_lv 8G
  lvreduce -L 8G /dev/my_vg/my_lv
  ```

---

### 🧪 Snapshot Example

```bash
lvcreate -L 1G -s -n my_snapshot /dev/my_vg/my_lv
```

This creates a snapshot of your volume—great for backups or testing changes.

---

### 🚀 Why Use LVM?

- Resize volumes without rebooting.
- Combine multiple disks into one logical space.
- Easily migrate data between disks.
- Create snapshots for safe experimentation.

</br></details>

---

<details><summary style="color: #fc4545ff">
34. How could you mount a volume in Linux?</summary><br><b>

    1. Identify the USB drive using the `lsblk` command.
    2. Create a directory to mount the USB drive into.
    3. Check if it formatted or not
    4. Mount the USB drive to the /media/pendrive directory using the `mount` command.
    5. Check the drive has been mounted by re-running lsblk.

</b></details>

---

<details><summary style="color: #fc4545ff">
35. What are Linux bootstrap processes?</summary><br><b>

Bootstrapping in computer science is **the technique for producing a self-compiling compiler**. That is compiler/assembler written in the source programming

    **The booting process takes the following 4 steps that we will discuss in greater detail:**
    1. BIOS Integrity check (POST)
    1. Loading of the Boot loader (GRUB2)
    1. Kernel initialization.
    1. Starting systemd, the parent of all processes.

</b></details>

---

<details><summary style="color: #fc4545ff">
36. Tell me about Linux file systems.</summary><br><b>

      The Linux filesystem unifies all physical hard drives and partitions into a single directory structure, this is how you sort your data inside the storage.

<img width="275" alt="image" src="https://github.com/Ahmed-Moourad/DevOps-Interview-Questions-for-Juniors/assets/112473376/c38ac75e-00ce-4d18-8f03-90ee27605f3e">

</b></details>

---

<details><summary style="color: #fc4545ff">
37. What’s WAF in Linux ?</summary><br><b>

    a firewall specifically designed to handle "web" traffic; that is, traffic using the HTTP protocol. Generally speaking, the role of a WAF is to inspect all HTTP traffic destined for a web server, discard "bad" requests, and pass "good" traffic on

</b></details>

---

<details><summary style="color: #fc4545ff">
38. What’s Selinux and how can use it?</summary><br><b>

SELinux defines access controls for the applications, processes, and files on a system. It uses security policies, which are a set of rules that tell SELinux what can or can't be accessed, to enforce the access allowed by a policy

</b></details>

---

<details><summary>
39. What’s the /dev/null directory?</summary><br><b>

In Linux, `/dev/null` isn’t actually a **directory**—it’s a **special device file** often called the **bit bucket** or **black hole** of the system.

---

### 🕳️ What Is `/dev/null`?

- It’s a **virtual device** that **discards all data written to it**.
- Reading from it returns **nothing** (EOF).
- It’s used to **suppress output** or **errors** from commands.

```bash
echo "Hello" > /dev/null   # Output disappears
ls /fakepath 2> /dev/null  # Suppresses error messages
```

---

### 🔐 Scenario: Searching `/var/log` for the word `"denied"`

You want to check for any access denials across system log files:

```bash
grep "denied" /var/log/* 2>/dev/null
```

---

### 📌 What Happens?

- ✅ Some files (like `/var/log/syslog`, `/var/log/auth.log`) are readable → You get matches.
- ❌ Others (like `/var/log/audit/audit.log`) may be **restricted to root** → You get `Permission denied`.

By redirecting `2>/dev/null`, you're telling the shell to **ignore error messages** from files you can’t access.

---

### 💡 Want to log errors instead?

Rather than discarding, you could redirect them to a separate file for review:

```bash
grep "denied" /var/log/* 1>matches.txt 2>errors.txt
```

Now:

- ✅ `matches.txt` has your useful results.
- ❌ `errors.txt` shows which files had permission issues.

---

### 📁 Is It a Directory?

Nope! Despite the name, `/dev/null` is a **character device file**, not a directory. If you try to treat it like a directory:

```bash
ls /dev/null/
```

You’ll get:

```ini
/dev/null: Not a directory
```

---

### 🧠 Why Is It Useful?

- **Clean logs**: Prevent clutter by discarding unwanted output.
- **Silent scripts**: Run commands quietly without showing errors.
- **Secure deletion**: Overwrite files with null bytes (e.g. `cat /dev/null > file.txt`).

---

</b></details>

## Linux Scenario Based Questions:

<details><summary>
Q: You notice a sudden spike in server CPU utilization. How would you troubleshoot and identify the root cause?</summary><br><b>

A: I would check CPU usage using `top` or `htop`, identify the culprit process with `ps` or `pidstat`, analyze logs for events, and optimize or scale resources accordingly.
</b></details>

---

<details><summary>
Q: A critical application on your Linux server is unresponsive. Walk me through the steps you would take to diagnose and resolve the issue.</summary><br><b>

A: I'd use `ps` and `top` to identify the hung process, check logs for errors, restart the application or services, and monitor for improvements.
</b></details>

---

<details><summary>
Q: You need to deploy a new version of a web application on a Linux server without causing downtime. Explain the steps you would take to achieve a zero-downtime deployment.</summary><br><b>

A: Implement a load balancer, deploy the new version on one server at a time, validate each step, and update the load balancer to include new servers.
</b></details>

---

<details><summary>
Q: A team member accidentally deleted important files on a Linux server. How would you recover the lost data?</summary><br><b>

A: I'd use file recovery tools like `extundelete` or `photorec`, avoid writing new data to prevent overwriting, and restore from backups if available.
</b></details>

---

<details><summary>
Q: Your Linux server is running out of disk space. What steps would you take to identify and resolve the issue, considering both short-term and long-term solutions?</summary><br><b>

A: Identify large files with `du` and `df`, remove unnecessary files, implement log rotation, and consider long-term solutions like additional storage.
</b></details>

---

<details><summary>
Q: Explain how you would set up and configure a basic firewall on a Linux server to enhance its security.</summary><br><b>

A: Use `iptables` or `firewalld` to set up rules, allow only necessary ports and services, and regularly review and update firewall rules.
</b></details>

---

<details><summary>
Q: Your team is working on a collaborative project, and you want to implement version control using Git on a Linux server. How would you set up and manage the Git repository?</summary><br><b>

A: Initialize a Git repository with `git init`, add and commit files, push to a central repository, and collaborate using branches and pull requests.
</b></details>

---

<details><summary>
Q: You want to monitor the performance of your Linux server over time. What tools and techniques would you use for performance monitoring and analysis?</summary><br><b>

A: Use tools like `sar`, `vmstat`, and `iostat` for monitoring, set up alerts for abnormal behavior, and consider long-term solutions like Prometheus.
</b></details>

---

<details><summary>
Q: You are responsible for securing a Linux server. Outline the security measures and best practices you would implement to protect against potential threats.</summary><br><b>

A: Keep the system and software updated, configure a firewall, implement strong user authentication, regularly audit and review system logs, and apply the principle of least privilege.
</b></details>

> Ref for this questions: <https://www.linkedin.com/posts/minakshi-chaudhari-7a0a26241_linux-devopscommunity-awsdevops-activity-7154113961519460352-YYcq?utm_source=share&utm_medium=member_desktop>

## Kubernetes Questions:

<details><summary>
40. What are Kubernetes architecture components and explain them?</summary><br><b>

The main componehnts of a Kubernetes cluster include: **Nodes, Image Registry, Pods**
\-------------------------------------------
**Kubernetes Core Components: Control Plane(Master Node):** - **kube-apiserver**. Provides an API that serves as the front end of a Kubernetes control plane. ... - **etcd**: The key-value store where all data relating to the cluster is stored - **kube-scheduler**. When a new Pod is created, this component assigns it to a node for execution based on resource requirements, policies, and ‘affinity’ specifications regarding geolocation and interference with other workloads. - **kube-controller-manager**. Although a Kubernetes cluster has several controller functions, they are all compiled into a single binary known as kube-controller-manager.
\-----------------------------------------------
**Node components include: (Worker Node)** - **kubelet**: Every node has an agent called kubelet. It ensures that the container described in PodSpecs is up and running properly. - **kube-proxy**: A network proxy on each node that maintains network nodes that allow for the communication from Pods to network sessions, whether inside or outside the cluster, using operating system (OS) packet filtering if available. - **container runtime**: Software responsible for running the containerized applications. Although Docker is the most popular, Kubernetes supports any runtime that adheres to the Kubernetes CRI (Container Runtime Interface).
</b></details>

---

<details><summary>
41. What’s the difference between Master and Worker Node?</summary><br><b>

**Worker Node**: - Do all the Work - Responsible for running the containers and doing any work assigned to them by the master node - Many nodes - Consist of **3** components: kubelet, kube-proxy, container runtime

    **Master Node**:
    - Create the control plane
    - Looks after scheduling and scaling applications. maintaining the state of the cluster.
    - 1 or two nodes
    - Consist of **4** components: etcd, kube controller manager, kube-API-server, kube-schedular

</b></details>

---

<details><summary>
42. What are service types?</summary><br><b>

    -  **ClusterIP** (default): Internal clients send requests to a stable internal IP address.

    -  **NodePort**: Clients send requests to the IP address of a node on one or more nodePort values that are specified by the Service.

    -  **LoadBalancer:** Clients send requests to the IP address of a network load balancer.

    -  **ExternalName**: Internal clients use the DNS name of a Service as an alias for an external DNS name.

    -  **Headless**: when you want a Pod grouping, but don't need a stable IP address.


    The **NodePort** type is an extension of the **ClusterIP** type. So a Service of the type NodePort has a cluster IP address.



    The **LoadBalancer** type is an extension of the **NodePort** type. So a Service of type **LoadBalancer** has a cluster IP address and one or more **nodePort** values.

![image](https://github.com/Ahmed-Moourad/DevOps-Interview-Questions-for-Juniors/assets/112473376/e4e43c46-7a7d-4e2f-9bd8-5b20aff34df5)

![image](https://github.com/Ahmed-Moourad/DevOps-Interview-Questions-for-Juniors/assets/112473376/e43b8466-69ab-48fa-a5b9-d22adaf53c3f)

</b></details>

---

<details><summary>
43. What’s the difference between deployment vs DaemonSet vs StatfulSet?</summary><br><b>

- **Deployments** and ReplicationControllers are meant for stateless usage and are rather lightweight.
- **Statefulsets**: is used for Stateful applications (DB), each replica of the pod will have its own state, and will be using its own Volume.
- **DaemonSet**: is a controller similar to **ReplicaSet** that ensures that the pod runs on all the nodes of the cluster.

  **A Daemonset will not run more than one replica per node**. Another advantage of using a Daemonset is that, if you add a node to the cluster, then the Daemonset will automatically spawn a pod on that node, which a deployment will not do

![image](https://github.com/Ahmed-Moourad/DevOps-Interview-Questions-for-Juniors/assets/112473376/aac25788-f74c-4d3e-9a15-7d0174fb3980)

![image](https://github.com/Ahmed-Moourad/DevOps-Interview-Questions-for-Juniors/assets/112473376/67c1aaa1-18e8-4384-ab7e-41f2a65aa832)

![image](https://github.com/Ahmed-Moourad/DevOps-Interview-Questions-for-Juniors/assets/112473376/df977628-dd54-481b-9b88-95a573f47be3)

</b></details>

---

<details><summary>
44. What’s the difference between ReplicaController and ReplicaSet?</summary><br><b>

The rolling-update command works with Replication Controllers, but won't work with a Replica Set.

</b></details>

---

<details><summary>
45. What is the difference between ReplicaSet and Deployment?</summary><br><b>

    - **A ReplicaSet** ensures that a specified number of pod replicas are running at any given time.
    - **Deployment** is a higher-level concept that manages ReplicaSets and provides declarative updates to Pods along with a lot of other useful features.

</b></details>

---

<details><summary>
46. How can create a variable for your deployment and how can secure it?</summary><br><b>

      **Secrets** can be mounted as data volumes or exposed as environment variables to be used by a container in a Pod.

Secrets can also be used by other parts of the system, without being directly exposed to the Pod.

</b></details>

---

<details><summary>
47. Is it possible to create multiple containers in one pod?</summary><br><b>

YES – but better be one container/Pod
because each container should do one task so if you have 2 containers in a pod and you are near to increase one container because its service/task has a lot of traffic ... then k8s will create a new pod with two containers that the second is not doing anything so you are wasting your compute capacity.

</b></details>

---

<details><summary>
48. What’s a Sidecar container?</summary><br><b>

    - Sidecar containers are containers that run along with the main container in a pod. You can define any number of sidecar containers to run alongside the main container
    - The sidecar containers can also share storage volumes with the main containers, allowing the main containers to access the data in the sidecars.
    - The primary application can run independently in one container while the sidecar hosts complementary processes and tools

</b></details>

---

<details><summary>
49. What’s CustomResourcesDefination (CRD)?</summary><br><b>

API resource allows you to define custom resources. Defining a CRD object creates a new custom resource with a name and schema that you specify. The Kubernetes API serves and handles the storage of your custom resource. The name of a CRD object must be a valid DNS subdomain name

</b></details>

---

<details><summary>
50. What’s kube-proxy?</summary><br><b>

a network proxy that runs on each node in your cluster, implementing part of the Kubernetes Service concept. kube-proxy maintains network rules on nodes. These network rules allow network communication to your Pods from network sessions inside or outside of your cluster

</b></details>

---

<details><summary>
51. What’s the difference between liveness vs readiness vs startup probes?</summary><br><b>

**liveness**:
**Liveness Probe**: Checks if a container is running properly and restarts it if the probe fails.
**Readiness Probe**: Checks if a container is ready to receive network traffic and delays routing until it becomes ready.
**Startup Prob**e: Checks the initial startup readiness of a container, helping differentiate slow starts from unresponsive containers.
</b></details>

---

<details><summary>
52. What’s the operator of the Database?</summary><br><b>

The DB Operator eases the pain of managing PostgreSQL and MySQL instances for applications running in Kubernetes. The Operator creates databases and makes them available in the cluster via Custom Resource. It is designed to support the on-demand creation of test environments in CI/CD pipelines.

</b></details>

---

<details><summary>
53. What are the static pods?</summary><br><b>

Static Pods are managed directly by the kubelet daemon on a specific node, without the API server observing them

</b></details>

---

<details><summary>
54. What are helm and helm charts?</summary><br><b>

Helm helps you manage Kubernetes applications — Helm Charts help you define, install, and upgrade even the most complex Kubernetes application. Charts are easy to create, version, share, and publish — so start using Helm and stop the copy-and-paste.
Helm uses a packaging format called charts. A chart is a collection of files that describe a related set of Kubernetes resources

</b></details>

---

<details><summary>
55. What’s custom resources in K8s?</summary><br><b>

A custom resource is an **extension of the Kubernetes API** that is not necessarily available in a default Kubernetes installation. It represents a customization of a particular Kubernetes installation. However, many core Kubernetes functions are now built using custom resources, making Kubernetes more modular

</b></details>

---

<details><summary>
56. What’s the difference between Ingress and IngressPolicy?</summary><br><b>

**Ingress Resource**: an object with a set of routing rules.
The Ingress concept lets you map traffic to different backends based on rules you define via the Kubernetes API.
**IngressPolicy** (Ingress rules) allows connections to all pods in the "default" namespace with the label "role=db" on TCP port 6379 from: any pod in the "default" namespace with the label "role=frontend" and any pod in a namespace with the label "project=myproject"

</b></details>

## **General Questions:**

---

<details><summary>
57. What’s CICD?</summary><br><b>

CI/CD is a method to frequently deliver apps to customers by introducing automation into the stages of app development.
continuous integration, continuous delivery, and continuous deployment.

</b></details>

---

<details><summary>
58. What’s Jenkins pipeline?</summary><br><b>

a suite of plugins that supports implementing and integrating continuous delivery pipelines into Jenkins. A continuous delivery pipeline is an automated expression of your process for getting software from version control right through to your users and customers.

</b></details>

---

<details><summary>
59. What’s Jenkins Master and Slave?</summary><br><b>

The Jenkins master acts to schedule the jobs, assign slaves, and send builds to slaves to execute the jobs. It will also monitor the slave state (offline or online) and get back the build result responses from slaves and display build results on the console output.

</b></details>

---

<details><summary>
60. What’s Jenkins Shared Library?</summary><br><b>

It is a feature that allows you to define reusable code in a version-controlled repository and share it across Jenkins pipelines. It promotes code reuse, and consistency, and simplifies pipeline maintenance.
A shared library in Jenkins is a collection of Groovy scripts shared between different Jenkins jobs
Each shared library requires users to define a name and a method of retrieving source code.
</b></details>

---

<details><summary>
61. What’s Java Spring Boot?</summary><br><b>

Java Spring Boot (Spring Boot) is a tool that makes developing web applications and microservices with Spring Framework faster and easier through three core capabilities: Autoconfiguration. An opinionated approach to configuration. The ability to create standalone applications.

</b></details>

---

<details><summary>
62. What’s the difference between Rolling Strategy and Blue-Green Strategy?</summary><br><b>

**Rolling deployments** follow a staggered delivery pattern that gradually replaces instances of the existing environment with updated versions.
**Blue-green deployments** involve creating a rigorously-tested second environment before completely shifting the current instance to the new environment.
</b></details>

---

<details><summary>
63. What’s SonarQube?</summary><br><b>

empowers all developers to write cleaner and safer code
Code Quality Assurance tool that collects and analyzes source code, and provides reports for the code quality of your project
</b></details>

---

<details><summary>
64. What’s API?</summary><br><b>

a set of functions and procedures allowing the creation of applications that access the features or data of an operating system, application, or another service

</b></details>

---

<details><summary>
65. How can writing a bash script?</summary><br><b>

    1. create a file using a vi editor(or any other editor). Name script file with extension.sh.
    2. Start the script with #! /bin/sh.
    3. Write some code.
    4. Save the script file as filename.sh.
    5. For executing the script type bash filename.sh.

</b></details>

---

<details><summary>
66. What’s the difference between `awk` vs `sed`?</summary><br><b>

**`sed`** is a command utility that works with streams of characters for searching, filtering and text processing
**`awk`** is more powerful and robust than sed with sophisticated programming constructs such as ifelse, while, do/while

</b></details>

---

<details><summary>
67. How can create variables in Ansible?</summary><br><b>

define a variable dynamically when you run a playbook, **use the --extra-vars option along with the key and value of the variable you want to define**. In this example, the key is my_var because that's the string referenced in the playbook, and the value is any string you want the variable to contain
</b></details>

---

<details><summary>
68. What are modules and tasks in Ansible playbook?</summary><br><b>

Ansible Playbooks are **lists of tasks that automatically execute against hosts**. Groups of hosts form your Ansible inventory. Each module within an Ansible Playbook performs a specific task

**Modules**: Standalone code units in Ansible for specific tasks on managed hosts.

**Tasks**: Actions in Ansible playbooks defining desired system state using modules.

</b></details>

---

<details><summary>
69. Difference between Dynamic Inventory and Multiple Inventory?</summary><br><b>

**Dynamic Inventory**: Retrieves inventory information dynamically from external sources.
**Multiple Inventory**: Allows the use of multiple static inventory files for organizing and managing inventory across different environments or projects.
Using inventory directories and multiple inventory sources. Static groups of dynamic groups. If your Ansible inventory fluctuates over time with hosts spinning up and shutting down in response to business demands, the static inventory solutions will not serve your needs.
Multiple Inventory:You may need to track hosts from multiple sources: cloud providers, LDAP, Cobbler, and/or enterprise CMDB systems.

</b></details>

---

<details><summary>
70. What’s the path of ansible configuration?</summary><br><b>

/etc/ansible/ansible. cfg

</b></details>

---

<details><summary>
71. What’s the difference between ansible and chef?</summary><br><b>

Ansible: uses YAML (easy), Agentless
Chef and Puppet: uses Ruby (Difficult), needs an agent and updates are a headache.

</b></details>

---

<details><summary>
72. What’s privilege escalation in Ansible?</summary><br><b>

Ansible uses existing privilege escalation systems to execute tasks with root privileges or with another user’s permissions. Because this feature allows you to ‘become’ another user, different from the user that logged into the machine (remote user), we call it become. The become keyword uses existing privilege escalation tools like _sudo_, _su_, _pfexec_, _doas_, _pbrun_, _dzdo_, _ksu_, _runas_, _machinectl_ and others.
</b></details>

---

<details><summary>
73. What’s Azure DevOps?</summary><br><b>

Azure DevOps supports a collaborative culture and set of processes that bring together developers, project managers, and contributors to develop

![image](https://github.com/Ahmed-Moourad/DevOps-Interview-Questions-for-Juniors/assets/112473376/d18bb3ef-b8c2-4fbc-a400-1a62fafde352)
</b></details>

---

<details><summary>
74. What’s Git forking?</summary><br><b>

Forking is a git clone operation executed on a server copy of a project's repo.
A fork in Git is simply a copy of an existing repository in which the new owner disconnects the codebase from previous committers. A fork often occurs when a developer becomes dissatisfied or disillusioned with the direction of a project and wants to detach their work from that of the original project.

</b></details>

---

<details><summary>
75. Is it better to fork or clone in Git?</summary><br><b>

If you would like to make changes directly to a repository you have permission to contribute to, then **cloning** will be the first step before we implement the actual changes and push.
If you don't have permission to contribute to the repository but would like to implement changes anyway, a **fork** is the way to go.

</b></details>

---

<details><summary>
76. What’s the difference between stateful vs stateless?</summary><br><b>

**stateless** system sends a request to the server and relays the response (or the state) back without storing any information.
**Stateful** systems expect a response, track information, and resend the request if no response is received.

- Stateless Protocol is a network protocol in which the Client sends a request to the server and the server responds back as per the given state.
- Stateful Protocol is a network protocol in which if a client sends a request to the server then it expects some kind of response, in case of no response then it resends the request.

</b></details>

---

<details><summary>
77. What’s a message broker? Or message queue (MQ)</summary><br><b>

Way of how the microservices communicate
A message broker is a software that enables applications, systems, and services to communicate with each other and exchange information. EX: redis, Rabbit MQ

</b></details>

---

<details><summary>
78. What’s CDN?</summary><br><b>

A content delivery network (CDN) refers to a geographically distributed group of servers which work together to provide fast delivery of Internet content. Ex: Amazon CloudFront.

</b></details>

---

<details><summary>
79. What are types of API?</summary><br><b>

Five types of APIs are:

1. Open API
2. Partner API 4) High-level
3. Internal API 5) Low-level API

</b></details>

---

<details><summary>
80. What is Web APIs ?</summary><br><b>

- Open APIs. Open APIs, also known as external or public APIs, are available to developers and other users with minimal restrictions. ...
- Internal APIs. In contrast to open APIs, internal APIs are designed to be hidden from external users. ...
- Partner APIs. ...
- Composite APIs. ...
- REST. ...
- JSON-RPC and XML-RPC. ...
- SOAP.

</b></details>

---

<details><summary>  
81. What’s the terraform state?</summary><br><b>

Terraform must store state about your managed infrastructure and configuration. This state is used by Terraform to map real world resources to your configuration, keep track of metadata, and to improve performance for large infrastructures. This state is stored by default in a local file named **"terraform.tfstate”**
but it can also be stored remotely, which works better in a team environment.

<style>
summary {
  font-weight: bold;
  font-size: 20px;
  cursor: pointer;
  color: #adc8d8ff;
}
</style>
