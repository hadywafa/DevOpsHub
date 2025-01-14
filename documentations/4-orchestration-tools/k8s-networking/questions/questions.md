# Questions

## Networking Fundamentals Questions

### Advanced Questions

#### 1. For each step for example Router to Internet when router modify the packet and Removed for internet transmission. Ethernet Header and then it comes back to router again how the router knows the removed data ? is he store it or what ?

- When the router modifies a packet and removes the Ethernet header for internet transmission, it does not need to store the removed data (like the Ethernet header) because the necessary information to reconstruct the packet when it returns is already contained within the IP and NAT tables.

#### 2. i need to go deep dive in NAT Table to understand how router public ip can know the data is for ip of pc1 not for ip of pc2 ?

- The NAT table is used to map the private IP addresses of devices on the local network to the public IP address of the router. When a packet is received by the router, it checks the NAT table to determine which device on the local network the packet is intended for. The router then forwards the packet to the appropriate device based on the NAT table entry.

#### 3. i installed 3 different wsl distro and i found that all have same ip how ? they should have unique ip from wsl 2 vm range ?

When you install multiple WSL distributions on Windows, they might appear to have the same IP address due to how WSL 2 manages networking. Here’s an explanation of why this happens and how WSL 2 handles IP addresses:

- WSL 2 Networking Basics

1. **WSL 2 Virtual Machine (VM)**:

   - WSL 2 runs a lightweight VM using a Linux kernel, and all your WSL distributions run inside this single VM.
   - This VM has its own IP address, and all WSL distributions share the same network namespace, meaning they use the same IP address for external communication.

2. **IP Address Sharing**:

   - The WSL 2 VM bridges the network between the Windows host and the WSL distributions. This means that when you check the IP address from within any WSL distribution, they will all show the same IP address, which is the IP address of the WSL 2 VM.

3. **Internal Networking**:
   - Internally, the WSL distributions can communicate with each other using localhost (127.0.0.1). They are essentially part of the same network namespace within the WSL 2 VM.

- Why All WSL Distributions Have the Same IP

- **Single Network Interface**: The WSL 2 VM has a single network interface that is shared by all running WSL distributions. Therefore, when you query the IP address within any WSL distribution, you get the IP address of the WSL 2 VM.
- **Shared Network Namespace**: WSL 2 distributions run within the same network namespace provided by the WSL 2 VM. This means they share the same network stack and consequently the same external IP address.

- Practical Implications

1. **Accessing Services**:

   - Services running in different WSL distributions can be accessed via localhost, which simplifies communication between them.
   - For example, if you run a web server in one WSL distribution, you can access it from another WSL distribution using `http://localhost:<port>`.

2. **Networking Isolation**:
   - Even though WSL distributions share the same external IP, they can run isolated processes. However, they can still communicate over the localhost network, making it easy to set up inter-process communication.

- Summary

- **Same IP Address**: All WSL distributions show the same IP address because they share the same network namespace within the WSL 2 VM.
- **Shared Network Namespace**: The WSL 2 VM handles networking for all distributions, resulting in a shared IP address.
- **Ease of Access**: This setup simplifies communication between WSL distributions using localhost.

If you need to differentiate network traffic or create isolated networks for different distributions, you would need to use additional networking tools or configurations, but for most typical development purposes, the shared IP and localhost access provided by WSL 2 is sufficient and convenient.
