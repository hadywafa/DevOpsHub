# Virtual Private Cloud

## Components

![alt text](images/vpc-classification.png)

- Each vpc must be in one region.
- Each vpc have multi nested subnets.
- Each subnet must be in one AZ.
- Private subnet has not public ips.
- Each subnet has range of ips.
- There is default created vpc per aws account

## Understanding IP in AWS

![alt text](images/understanding-ip-in-aws.png)

### each byte can contain 255 possible numbers

![alt text](images/each-byte-can-contain-255-possible-numbers.png)

### network devices working with binary data

![alt text](images/network-devices-working-with-binary-data.png)

### IP = Network Number + Host Number

![alt text](images/ip-form.png)

### Class full addressing (old)

![alt text](images/classfull-addressing-1.png)
![alt text](images/classfull-addressing-2.png)

### CIDR Classless Inter-Domain Routing (new)

![alt text](images/cidr-1.png)
![alt text](images/cidr-2.png)
![alt text](images/cidr-3.png)
![alt text](images/cidr-4.png)
![alt text](images/cidr-5.png)
![alt text](images/cidr-6.png)
![alt text](images/cidr-7.png)

## Design VPC subnets in AWS

![alt text](images/private-ips-from-iana.png)

![alt text](images/private-ips-considrations.png)

### We create subnets from host id not from network id

![alt text](images/subnets-from-host-id-1.png)

![alt text](images/subnets-from-host-id-2.png)

### Calculation of Subnets

![alt text](images/network-to-create-subnets-from-it.png)

- To identical subnets of **/17**
![alt text](images/calc-subnets-ex1-1.png)
![alt text](images/calc-subnets-ex1-2.png)

- To identical subnets of **/18**
![alt text](images/calc-subnets-ex2-1.png)
![alt text](images/calc-subnets-ex2-2.png)

- To mixed size subnets
 ![alt text](images/calc-subnets-ex3.png)

- CIDR address should not overlaps with existing subnet CIDR with
![alt text](images/calc-subnets-note.png)

### Reserved IPs for any subnets

![alt text](images/reserved-ips-for-any-subnets.png)

## Example Design VPC subnets in AWS

![alt text](images/example-design-vpc-subnets-in-aws.png)

## Network Connections

![alt text](images/network-connection-getway.png)

### 1. Peering

- **Purpose**: Connects two VPCs privately.
- **Use Case**: Allows resources in different VPCs to communicate as if they were within the same network.
- **Benefits**: Low latency, no bandwidth bottleneck, and cost-effective for inter-VPC traffic.

### 2. Transit Gateway

- **Purpose**: Acts as a central hub to connect multiple VPCs, on-premises networks, and remote networks.
- **Use Case**: Simplifies complex network architectures by centralizing connections.
- **Benefits**: Scalable, simplifies routing, reduces peering connections, and improves management.

### 3. AWS Direct Connect

- **Purpose**: Provides a dedicated network connection from on-premises data centers to AWS.
- **Use Case**: High-throughput, low-latency access to AWS services.
- **Benefits**: Consistent network performance, increased bandwidth, and reduced data transfer costs.

### 4. AWS Site-to-Site VPN

- **Purpose**: Establishes a secure and encrypted connection between on-premises networks and AWS.
- **Use Case**: Extends your on-premises network to AWS securely over the internet.
- **Benefits**: Cost-effective, quick setup, secure communication, and redundancy.

### 5. Internet Gateway

- **Purpose**: Enables communication between instances in a VPC and the internet.
- **Use Case**: Allows instances to receive incoming traffic from the internet and send outbound traffic to the internet.
- **Benefits**: Scalability, high availability, and seamless internet access for VPC resources.

### 6. NAT Gateway

- **Purpose**: Allows instances in a private subnet to access the internet while preventing inbound traffic from the internet.
- **Use Case**: Secure outbound internet access for instances in private subnets.
- **Benefits**: Managed service, high availability, and scalability without managing NAT instances.

### Summary

- **Peering**: Direct VPC-to-VPC connection.
- **Transit Gateway**: Central hub for connecting multiple networks.
- **AWS Direct Connect**: Dedicated physical connection to AWS.
- **AWS Site-to-Site VPN**: Secure connection over the internet to AWS.
- **Internet Gateway**: Internet access for VPC resources.
- **NAT Gateway**: Outbound internet access for private subnet instances.

These gateways and connections help create a robust, scalable, and secure network infrastructure within AWS, catering to different connectivity needs.
