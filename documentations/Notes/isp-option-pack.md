# Configuring a Static Public IP for a VM Using One-to-One NAT: Understanding ISP Services

When purchasing a static IP service from your ISP, it’s important to understand how the service works and how it affects your network setup. This topic covers how your ISP’s **Option Pack 1** works, and how to configure your router and VM to use the static public IP effectively. Additionally, it clarifies common misconceptions about static IP allocation and introduces an alternative package called **Option Pack 2** that provides multiple public IPs.

## **1. Understanding Your ISP’s Option Pack 1**

When you subscribed to your ISP’s **Option Pack 1** package, you were assigned a **static public IP** for your **router**. This means the public IP address for your network, visible on the internet, will no longer change. The key points about this service are:

- **Static IP for Router**: Your router has a single static public IP, in this case, `81.10.0.7`, which will not change over time.
- **No Additional Public IPs**: This package only provides the static IP for the router, not for individual devices behind the router. Devices on your local network (like your VM) will still use **private IPs**.
- **One-to-One NAT**: If you want to make a specific device (e.g., your VM) accessible from the internet, you’ll need to use **One-to-One NAT** to map the router’s public IP to the private IP of the device.

### Common Misconception:

Initially, you expected the ISP to provide a **separate public IP** for personal use (e.g., for your VM). However, in this package, **the only static IP** provided is the one assigned to your router. All devices behind the router will need to use NAT to be accessible from the internet.

---

## **2. Setting Up One-to-One NAT for Your VM**

To make your VM accessible from the internet using the static public IP (`81.10.0.7`), you can set up **One-to-One NAT** on your router. This allows traffic from the public IP to be forwarded to a specific device on your local network.

### Steps:

1. **Assign a Static Private IP to Your VM**:

   - In your local network, assign a static private IP to your VM, such as `192.168.1.50`. This ensures that the IP doesn’t change and the One-to-One NAT rule remains valid.

2. **Configure One-to-One NAT on the Router**:
   - Log into your router’s admin interface.
   - Navigate to the **Port Forwarding** or **NAT** settings.
   - Set up a One-to-One NAT rule to map the **public IP (`81.10.0.7`)** to the **private IP (`192.168.1.50`)** of your VM.
   - Forward any necessary ports (e.g., SSH on port 22, HTTP on port 80).

### Example NAT Rule:

- **Public IP**: `81.10.0.7`
- **Private IP**: `192.168.1.50`
- **Ports**: Forward required ports such as `22` for SSH and `80` for HTTP.

---

## **3. Testing External Access to Your VM**

Once the One-to-One NAT is set up, you can test accessing your VM using the router’s public static IP.

1. **SSH Access**:

   ```bash
   ssh user@81.10.0.7
   ```

2. **HTTP Access** (if you have a web server running):
   - Open a web browser and navigate to `http://81.10.0.7`.

---

## **4. Security Considerations**

Whenever you expose devices on your local network to the public internet, it’s important to ensure proper security:

- **Strong Passwords**: Ensure all user accounts on the VM use strong, unique passwords.
- **SSH Key Authentication**: Disable password-based SSH logins and use key-based authentication.
- **Firewall**: Configure firewalls on both the router and the VM to allow only necessary traffic.

---

## **5. Option Pack 2: Additional Public IPs**

Your ISP also offers a package called **Option Pack 2**, which provides **5 public IPs**. If you need more than one public IP (e.g., if you want multiple devices, such as multiple VMs, to have their own public IPs), this package might be a better option.

### How Option Pack 2 Works:

- **5 Public IPs**: The ISP will provide you with a block of 5 public IPs, which can be assigned to individual devices in your network.
- **Direct Public Access**: Each device could have its own public IP, eliminating the need for NAT.
- **Use Cases**: This is useful if you have multiple services or servers that need to be accessed independently from the internet.

---

## **Summary**

### **Option Pack 1**:

- Provides **one static public IP** for your router.
- You use **One-to-One NAT** to map this public IP (`81.10.0.7`) to devices in your local network, like your VM.
- **No additional public IPs** are provided for individual devices.

### **Option Pack 2**:

- Provides **5 public IPs**, allowing you to assign public IPs directly to multiple devices on your network.
- Ideal for scenarios where multiple services or devices need their own public IPs.

By configuring One-to-One NAT with **Option Pack 1**, you have successfully made your VM accessible from the internet using your router's public static IP. For more advanced setups, such as assigning multiple public IPs to different devices, **Option Pack 2** would be the next step.
