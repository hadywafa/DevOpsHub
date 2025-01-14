# Namespaces in Kubernetes

![alt text](images/ns.png)

## What is Namespaces

**namespaces** are a logical construct for organizing resources, not a physical container. Resources are scheduled onto nodes independently of their namespace, and the namespace just provides a way to manage and isolate them logically.

1. **Namespaces as Virtual Groupings:**

   - **Namespaces** in Kubernetes are indeed more like a virtual grouping or a label for resources. They are not tied to any specific node or physical location within the cluster.
   - Think of a namespace as a label that categorizes and isolates resources like Pods, Services, and ConfigMaps within the cluster. It provides a way to group related resources together, but it doesn’t dictate where those resources physically live (i.e., on which nodes they run).

2. **Namespace Across Nodes:**

   - Since a namespace is a cluster-wide construct, it doesn’t get duplicated across nodes. It exists across the entire cluster, and any resource within that namespace can be scheduled on any node within the cluster, depending on resource availability and scheduling policies.
   - For example, you could have 10 Pods in the `dev` namespace. Some of these Pods might be running on Node A, some on Node B, and so on. The namespace (`dev`) organizes these Pods logically, but their physical placement on nodes is handled separately by the Kubernetes scheduler.

3. **Namespace as a Logical Container:**
   - **Namespace** does not physically contain resources; it’s more of a logical container or grouping. The physical placement of resources is managed by Kubernetes independently of namespaces.
   - The namespace helps with managing, organizing, and applying policies (like network policies or resource quotas) to resources, but it doesn’t dictate where those resources are physically located in the cluster.

## Why Use Namespaces?

- **Isolation**: Separate environments (e.g., dev, test, prod).
- **Resource Management**: Manage resources and quotas for teams or projects.
- **Security**: Apply access controls to enhance security.
- **Organization**: Logically organize resources within the cluster.

## Commands and Operations

- **Create a namespace**:

  ```sh
  kubectl create namespace development
  ```

- **List all namespaces**:

  ```sh
  kubectl get namespaces
  ```

- **Describe a namespace**:

  ```sh
  kubectl describe namespace development
  ```

- **Delete a namespace**:

  ```sh
  kubectl delete namespace development
  ```

## Default Namespaces

1. **default**:

   - **Purpose**: Default namespace for objects without a specified namespace.
   - **Use Case**: General-purpose; resources created without a namespace go here.

2. **kube-system**:

   - **Purpose**: Contains objects created by the Kubernetes system.
   - **Use Case**: System components like the API server, scheduler, and controller manager.

3. **kube-public**:

   - **Purpose**: Readable by all users, including unauthenticated ones.
   - **Use Case**: Resources that should be publicly accessible.

4. **kube-node-lease**:
   - **Purpose**: Holds lease objects associated with each node, aiding in node health checks.
   - **Use Case**: Used for node heartbeats to improve node failure detection performance.

## Examples

1. **Creating a Namespace**:

   ```sh
   kubectl create namespace development
   ```

2. **Deploying a Pod in a Namespace**:

   ```yaml
   apiVersion: v1
   kind: Pod
   metadata:
     name: my-pod
     namespace: development
   spec:
     containers:
       - name: my-container
         image: nginx
   ```

   ```sh
   kubectl apply -f pod.yaml
   ```

3. **Switching Between Namespaces**:

   ```sh
   kubectl config set-context --current --namespace=development
   ```

## Benefits and Best Practices

1. **Organize Resources**: Separate environments or teams.
2. **Resource Quotas**: Control resource usage with quotas.
3. **Access Control**: Manage access with RBAC (Role-Based Access Control).
4. **Avoid Overusing**: Keep the number of namespaces manageable.

## Notes

- you can't access resources in a namespace from another namespace except **services**.
- you can access **services** in another namespace by using the service name and the namespace name.
  - e.g., `my-service.my-namespace.svc.cluster.local`.
- **volumes** and **nodes** are cluster-wide resources and not bound to a namespace.

## kubens

`kubens` is a command-line tool that simplifies switching between Kubernetes namespaces. It enhances the `kubectl` experience by providing an easy way to change the current namespace context.

### Features

1. **Quick Switching**: Easily switch between namespaces.
2. **Namespace Listing**: Lists all available namespaces.
3. **Interactive Mode**: Allows selecting the desired namespace interactively.
4. **Integration**: Works seamlessly with `kubectl`.

### Installation

- **Using Homebrew**: `brew install kubectx`
- **From Source**: Download and move the binary to a directory in your `$PATH`.

### Usage

- **List namespaces**: `kubens`
- **Switch namespace**: `kubens <namespace-name>`

#### Example

1. List all namespaces:

   ```sh
   kubens
   ```

2. Switch to the `development` namespace:

   ```sh
   kubens development
   ```

3. Switch back to the previous namespace:

   ```sh
   kubens -
   ```

### Benefits

1. **Efficiency**: Reduces the number of commands needed.
2. **Convenience**: Avoids repetitive typing of namespace names.
3. **Productivity**: Enhances productivity by quick access to different namespaces.
4. **Clarity**: Keeps the current namespace context clear.
