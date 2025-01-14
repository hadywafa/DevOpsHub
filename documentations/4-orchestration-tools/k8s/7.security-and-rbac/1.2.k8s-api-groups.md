# **Kubernetes API Groups**

Kubernetes organizes resources into **API groups** to provide a modular and flexible way to extend the Kubernetes API. Each group contains one or more resources (such as `pods`, `deployments`, `configmaps`), logically grouped by function or usage.

## **How API Groups Work**

1. **Core API Group (`""`)**:

   - No explicit group name is required.
   - Contains fundamental resources like **Pods, Services, Nodes**, and **Namespaces**.
   - These are critical resources necessary for the operation of any Kubernetes cluster.

2. **Named API Groups**:

   - API groups other than the core group have explicit names.
   - They typically follow the pattern `<group>/<version>`, such as:
     - `apps/v1` – Resources like **Deployments** and **StatefulSets**.
     - `rbac.authorization.k8s.io/v1` – RBAC-related resources like **Roles** and **RoleBindings**.
     - `batch/v1` – Resources like **Jobs** and **CronJobs**.

3. **API Versions**:
   - Groups can have multiple versions (e.g., `v1`, `v1beta1`).
   - Newer versions often introduce new features or improvements over older versions.

## **Listing API Groups and Resources with kubectl**

You can use the following command to get a **list of all API groups and their resources**:

```bash
kubectl api-resources
```

### **Example Output:**

```plaintext
NAME                              SHORTNAMES   APIGROUP                        NAMESPACED   KIND
pods                              po           ""                              true         Pod
services                          svc          ""                              true         Service
deployments                       deploy       apps                            true         Deployment
jobs                                           batch                           true         Job
cronjobs                          cj           batch                           true         CronJob
configmaps                        cm           ""                              true         ConfigMap
roles                                         rbac.authorization.k8s.io      true         Role
clusterroles                                  rbac.authorization.k8s.io      false        ClusterRole
```

## **Explanation of the Output**

1. **NAME**:  
   The name of the resource, such as `pods` or `deployments`.

2. **SHORTNAMES**:  
   Short forms that can be used with `kubectl` (e.g., `po` for `pods`).

3. **APIGROUP**:  
   The API group to which the resource belongs. If the value is empty (`""`), the resource belongs to the **core API group**.

4. **NAMESPACED**:  
   Indicates whether the resource exists within a namespace.

   - **true**: The resource is scoped to a specific namespace.
   - **false**: The resource is cluster-wide.

5. **KIND**:  
   The type of the resource, such as **Pod**, **Deployment**, or **Service**.

## **Practical Example: Filtering API Groups and Resources**

If you want to list **only the resources** from a specific API group (e.g., `apps`), you can filter them:

```bash
kubectl api-resources --api-group=apps
```

**Example Output:**

```plaintext
NAME          SHORTNAMES   APIGROUP   NAMESPACED   KIND
deployments   deploy       apps       true         Deployment
statefulsets  sts          apps       true         StatefulSet
daemonsets    ds           apps       true         DaemonSet
```

## **Use Case: Accessing a Specific Resource with kubectl**

You can access resources in different API groups by specifying their **group and version**. For example:

```bash
kubectl get deployments.apps
kubectl get cronjobs.batch
kubectl get roles.rbac.authorization.k8s.io
```

## **Summary**

- **Core API group** (empty group name `""`) contains essential resources like **Pods, Services, and Nodes**.
- **Named API groups** (e.g., `apps`, `batch`, `rbac.authorization.k8s.io`) logically organize related resources.
- **Resources** can be **namespaced** or **cluster-wide**.
- Use `kubectl api-resources` to explore API groups and their resources.
