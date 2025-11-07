# iptable, nftable, IPVS

## Iptables

**Iptables** is a user-space utility program that allows a system administrator to configure the IP packet filter rules of the Linux kernel firewall, implemented as different Netfilter modules. Iptables is used to set up, maintain, and inspect the tables of IP packet filter rules.

**Key Points:**

- **Rule Management:** Manages rules for incoming, outgoing, and forwarded packets.
- **Tables:** Divided into different tables (filter, nat, mangle, raw).
- **Chains:** Each table contains built-in chains (INPUT, FORWARD, OUTPUT).
- **Common Use Cases:** Firewall, NAT (Network Address Translation), packet filtering.

## Nftables

**Nftables** is a subsystem of the Linux kernel that provides filtering and classification of network packets/datagrams/frames. It replaces the legacy iptables framework.

**Key Points:**

- **Unified Framework:** Combines functionality of iptables, ip6tables, arptables, and ebtables.
- **Simplified Syntax:** Easier and more consistent rule syntax compared to iptables.
- **Better Performance:** Reduces the number of system calls needed for rule management.
- **Compatibility:** Includes backward compatibility with iptables rules through the `iptables-translate` tool.

## IPVS (IP Virtual Server)

**IPVS** is an advanced layer 4 load balancer implemented inside the Linux kernel. It’s designed for load balancing TCP and UDP-based services.

**Key Points:**

- **Load Balancing:** Distributes network traffic across multiple servers.
- **Scheduler Algorithms:** Supports various scheduling algorithms like round-robin, least connections, etc.
- **Direct Routing:** Can perform Direct Server Return (DSR), NAT, and tunnel-based routing.

## Differences Between Iptables, Nftables, and IPVS

1. **Functionality:**

   - **Iptables/Nftables:** Primarily used for packet filtering, NAT, and firewall functionalities.
   - **IPVS:** Used for load balancing and service routing.

2. **Complexity:**

   - **Iptables:** Has a more complex and less consistent syntax.
   - **Nftables:** Provides a more streamlined and consistent rule syntax.
   - **IPVS:** Focuses on load balancing and is relatively straightforward in its configuration.

3. **Performance:**
   - **Iptables:** Less efficient for managing large sets of rules.
   - **Nftables:** More efficient and performs better with large rule sets.
   - **IPVS:** Highly efficient for load balancing operations.

## Usage in Kubernetes

**Kubernetes (k8s)** commonly uses iptables and IPVS for different aspects of networking and service management.

1. **Iptables in Kubernetes:**

   - **Kube-proxy:** Uses iptables to handle network traffic routing for Kubernetes Services. It sets up rules to forward traffic to appropriate pod IPs.
   - **Advantages:** Simple and works well for small to medium clusters.
   - **Limitations:** Can become slow and less efficient with very large numbers of services and endpoints.

2. **IPVS in Kubernetes:**
   - **Kube-proxy with IPVS Mode:** Offers a more scalable and high-performance alternative to iptables mode.
   - **Advantages:** Better performance and scalability. Handles large numbers of services and endpoints more efficiently.
   - **Scheduler Algorithms:** Allows the use of advanced load balancing algorithms.

### Common Usage in Kubernetes

- **Kube-proxy with iptables:** Suitable for smaller clusters. Simpler but less performant with many services.
- **Kube-proxy with IPVS:** Recommended for larger clusters. Provides better performance and scalability.

### Example Commands

**Iptables Example:**

```sh
# List all iptables rules
iptables -L

# Add a rule to allow incoming SSH connections
iptables -A INPUT -p tcp --dport 22 -j ACCEPT
```

**Nftables Example:**

```sh
# List all nftables rules
nft list ruleset

# Add a rule to allow incoming SSH connections
nft add rule ip filter input tcp dport 22 accept
```

**IPVS Example:**

```sh
# List IPVS services and their servers
ipvsadm -L -n

# Add a virtual server and real servers
ipvsadm -A -t 192.168.0.1:80 -s rr
ipvsadm -a -t 192.168.0.1:80 -r 192.168.0.2:80 -m
ipvsadm -a -t 192.168.0.1:80 -r 192.168.0.3:80 -m
```

## kube-proxy Modes in Kubernetes

By default, Kubernetes uses iptables for network traffic routing and service management through kube-proxy. However, you can configure kube-proxy to use IPVS for better performance and scalability.

1. **iptables Mode:**

   - This is the default mode used by kube-proxy.
   - It uses iptables rules to handle network traffic routing to services.
   - Suitable for small to medium-sized clusters but can become less efficient with a large number of services and endpoints.

2. **IPVS Mode:**
   - An alternative to iptables mode.
   - Provides better performance and scalability for large clusters.
   - Supports advanced load balancing algorithms.

### Configuring kube-proxy to Use IPVS

To configure kube-proxy to use IPVS, you can set the `--proxy-mode` flag to `ipvs` in the kube-proxy configuration. Here's an example:

1. **Edit kube-proxy ConfigMap:**

   ```sh
   kubectl edit cm kube-proxy -n kube-system
   ```

2. **Update the ConfigMap to enable IPVS:**

   ```yaml
   apiVersion: v1
   kind: ConfigMap
   metadata:
     name: kube-proxy
     namespace: kube-system
   data:
     config.conf: |
       kind: KubeProxyConfiguration
       apiVersion: kubeproxy.config.k8s.io/v1alpha1
       mode: "ipvs"
       ipvs:
         scheduler: "rr"  # Choose an appropriate IPVS scheduler
   ```

3. **Ensure IPVS modules are loaded:**

   You need to make sure that the required IPVS kernel modules are loaded on all nodes. You can load these modules using the following commands:

   ```sh
   modprobe ip_vs
   modprobe ip_vs_rr
   modprobe ip_vs_wrr
   modprobe ip_vs_sh
   modprobe nf_conntrack_ipv4
   ```

   You can also add these modules to `/etc/modules` to load them at boot.

4. **Restart kube-proxy:**

   ```sh
   kubectl delete pod -n kube-system -l k8s-app=kube-proxy
   ```

### Why Not nftables?

While nftables is a modern replacement for iptables and offers a more efficient and streamlined rule management system, Kubernetes has not yet adopted it by default for several reasons:

- **Compatibility:** iptables is widely used and supported across many environments. Transitioning to nftables would require extensive compatibility testing and potentially significant changes to existing setups.
- **Stability and Maturity:** iptables has been around for a long time and is considered stable and mature. While nftables is also stable, the widespread adoption of iptables makes it the default choice.
- **Community and Ecosystem:** The Kubernetes community and ecosystem have built many tools and practices around iptables. Shifting to nftables would require updating a lot of documentation, scripts, and tooling.

In conclusion, while nftables offers several advantages over iptables, Kubernetes continues to use iptables by default, with the option to use IPVS for improved performance in larger clusters.

## Summary

In summary, **iptables** and **nftables** are used for general packet filtering and firewall management, with **nftables** being the more modern and efficient option. **IPVS** is used specifically for load balancing and is commonly used in Kubernetes for high-performance service routing. Kubernetes can use either **iptables** or **IPVS** for service proxying, with IPVS offering better performance for large clusters.
