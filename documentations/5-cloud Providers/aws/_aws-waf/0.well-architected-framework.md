# AWS Well-Architected Framework

The Well-Architected Framework enables architects to build secure, highly performing, resilient, and efficient architectures on AWS.

- The framework provides a consistent approach for AWS partners and customers to evaluate their architectures on AWS for security, performance, reliability, cost, sustainability, and operational excellence.
- It can be used to measure how an architecture conforms to best practices and define areas of improvements.
- The main goal is to deliver the intended business value by designing and operating sound architectures on AWS.

**The 6 Pillars:**

1. Operational Excellence
2. Security
3. Reliability
4. Performance Efficiency
5. Cost Optimization
6. Sustainability

## **1. Operational Excellence**

Defines and focuses on how an organization can support its business objectives and its ability to run workloads effectively, how to gain insight into its operations, and how to continuously improve operational processes and procedures.

**Design principles:**

- Perform operations as code (IaC and Operations Procedures scripting).
- Make frequent, small, reversible changes.
- Refine operations procedures frequently.
- Anticipate failure (Simulation, testing).
- Learn from all operational failures.

**Benefits:**

- Build architectures that provide insight to their status.
- Architectures will be enabled for effective and efficient operation and event response.
- Architectures can continue to improve and support the business goals.

## **2. Security**

The security pillar defines how an organization can use cloud technologies to protect data, systems, and assets in a way that can improve the architecture’s security posture when implementing workloads in AWS.

**Design principles:**

- Implement a strong identity foundation.
- Enable traceability.
- Apply security at all layers.
- Automate security best practices (scripts, security as code).
- Protect data in transit and at rest.
- Keep people away from data (avoid manual processing or direct access).
- Prepare for security events (use incident response simulation, use automation for detection, remediation, and recovery. Use incident management and investigation tools)

## **3. Reliability**

The Reliability pillar covers the workload’s ability to perform its intended function correctly and consistently when it’s expected to.

**Design principles:**

- Automatically recover from failure (detection, remediation, recovery).
- Test recovery procedures.
- Scale horizontally to increase aggregate workload availability.
- Stop guessing capacity.
- Manage change in automation.

**Reliability of a workload depends on the workload’s Resiliency The definition of Resiliency is the ability of a workload to:**

- Recover from infrastructure or service disruptions,
- Dynamically acquire computing resources to meet demand, and
- Mitigate disruptions, such as misconfigurations or transient network issues

## **4. Performance Efficiency**

The focus of the performance efficiency pillar is on the ability to use computing resources efficiently to meet the workload requirements and how to maintain efficiency as demand changes and technologies evolve.

**Design principles:**

- Democratize advanced technologies (use provider-managed services).
- Go global in minutes.
- Use serverless architectures.
- Experiment more often.
- Consider mechanical sympathy (Use services and technologies that align to the requirements).

**Areas to focus on:**

- Selection of resources.
- Review the choices on a regular basis.
- Monitoring to be aware of any deviance.
- Make trade-offs to improve performance (caching, compression..etc).

## **5. Cost Optimization**

The focus of this pillar is to allow customers to build and operate cost-aware workloads that achieve business outcomes while minimizing costs.This will allow organizations to maximize their return on investment in the cloud.

**Design principles:**

- Implement cloud financial management.
- Adopt a consumption model.
- Measure overall efficiency.
- Stop spending money on undifferentiated heavy lifting.
- Analyze and attribute expenditure (cost allocation tags and cost centers).

**The five focus areas for cost optimization in the cloud:**

- Practice Cloud Financial Management.
- Expenditure and usage awareness.
- Cost-effective resources.
- Manage demand and supplying resources.
- Optimize over time.

## **6. Sustainability**

The sustainability pillar addresses the long-term environmental, economic, and societal impact of your business activities.Example areas include environmental impact and energy consumption.

**Design Principles:**

- Understand your impact.
- Establish sustainability goals (compute and storage required per transaction).
- Maximize utilization (right-size your workload to minimize the overall hosts used in AWS – Energy consumption).
- Adopt newer, more efficient, hardware and software offerings from AWS services or third parties (energy consumption).
- Use managed services.

## **Well Architect Tool (WA Tool)**

Is a free service from AWS based on the Well Architected Framework.

- Provides a consistent process to review and measure an architecture against the framework’s best practices.
- Provides recommendations to ensure an architecture is reliable, secure, efficient, and cost-effective.

## **Summary**

| Pillar Name            | Description                                                                                        |
| ---------------------- | -------------------------------------------------------------------------------------------------- |
| Operational Excellence | Focuses on running, monitoring, and continuously improving support processes for solutions in AWS. |
| Security               | Emphasizes protecting your solution and data in AWS.                                               |
| Reliability            | Deals with handling disruptions and scaling resources to meet demands.                             |
| Performance Efficiency | Ensures efficient use of resources while adapting to changes in demand and technology.             |
| Cost Optimization      | Aims to reduce costs while maintaining the effectiveness of the other pillars.                     |
| Sustainability         | Considers the environmental impact of your workload.                                               |

## **References**

1. [Well Architected Framework Explain](https://aws.amazon.com/architecture/well-architected/)
2. [Well Architected Framework Labs](https://www.wellarchitectedlabs.com/well-architected-tool/)
