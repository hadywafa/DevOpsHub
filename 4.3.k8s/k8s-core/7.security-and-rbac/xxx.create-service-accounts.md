# Service Accounts in Kubernetes

## What is a Service Account?

A Service Account in Kubernetes is a special type of account used by processes running inside pods to interact with the Kubernetes API. Unlike regular user accounts, which are used by humans, service accounts are intended for applications, controllers, or any other automated processes that need to access Kubernetes resources.

Service accounts provide a secure and managed way to grant specific permissions to these processes, ensuring they only have the access they need.

## Why Use Service Accounts?

- **Security**: Service accounts help enforce the principle of least privilege by assigning only the necessary permissions to the processes running in your pods.
- **Isolation**: Each service account can be isolated, ensuring that different applications or processes have distinct access levels.
- **Auditability**: Actions performed by service accounts are logged, making it easier to track and audit API interactions.

## How to Create a Service Account

### 1. **Create the Service Account**

- A service account is used by processes within a pod to interact with the Kubernetes API. To create a service account:

- Kubernetes no longer automatically creates service account tokens starting from Kubernetes v1.24. This change is part of the security enhancements in Kubernetes to avoid unnecessary exposure of tokens that might not be used.

```bash
kubectl create serviceaccount <service-account-name>
```

```bash
kubectl create serviceaccount jenkins --dry-run=client -o yaml > jenkins-sa.yaml
```

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: jenkins
  namespace: default
```

#### Apply the manifest

```bash
kubectl apply -f jenkins-sa.yaml
```

### 2. **Create Tokens for Service Account**

- Kubernetes no longer automatically creates service account tokens starting from Kubernetes v1.24. This change is part of the security enhancements in Kubernetes to avoid unnecessary exposure of tokens that might not be used.

#### Long-lived Tokens

As its name indicates, a long-lived token is one that never expires. Hence, it is less secure and discouraged to use.
Although not recommended, K8s allows us to create a long-lived token. It is achieved in two different steps:

```yaml
# jenkins-secret.yaml
apiVersion: v1
kind: Secret
type: kubernetes.io/service-account-token
metadata:
  name: jenkins-secret
  annotations:
    kubernetes.io/service-account.name: jenkins
```

```bash
kubectl apply -f jenkins-secret.yaml
```

```bash
kubectl get secret jenkins-secret -o jsonpath='{.data.token}' | base64 --decode
```

#### Short-lived Tokens

Short-lived tokens are more secure than long-lived tokens. They have a limited duration and are automatically rotated by Kubernetes.

Created Token is not stored in the cluster. It is only returned to the user who created it. and it is not possible to retrieve it again.

```bash
kubectl create token <service-account-name> --duration=<duration>
```

```bash
kubectl create token jenkins --duration=7776000s
```

### 3. **Assign Permissions to the Service Account**

Once the service account is created, you need to assign permissions by binding it to a `Role` or `ClusterRole`. This is done using a `RoleBinding` or `ClusterRoleBinding`.

**Role:**

```bash
kubectl create role cicd-role \
--verb=create,update,list \
--resource=deployments.apps,services \
--dry-run=client -o yaml > cicd-role.yaml
```

```yaml
# cicd-role.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  creationTimestamp: null
  name: cicd-role
rules:
  - apiGroups:
      - ""
    resources:
      - services
    verbs:
      - create
      - update
      - list
  - apiGroups:
      - apps
    resources:
      - deployments
    verbs:
      - create
      - update
      - list
```

**RoleBinding:**

```bash
kubectl create rolebinding bind-cicd-role-to-jenkins \
--role=cicd-role \
--serviceaccount=default:jenkins \
--dry-run=client -o yaml > bind-cicd-role-to-jenkins-sa.yaml
```

```yaml
# bind-cicd-role-to-jenkins-sa.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  creationTimestamp: null
  name: bind-cicd-role-to-jenkins
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: cicd-role
subjects:
  - kind: ServiceAccount
    name: jenkins
    namespace: default
```

### 4. **Test the Token**

You can test the certificate by using it to authenticate with the Kubernetes API server:
Make sure there is no ~/.kube/config file or the KUBECONFIG environment variable set.

```bash
kubectl get deployments --server=https://<api-server-endpoint>:6443  --token=<token> --insecure-skip-tls-verify

# Example => Private IP ✅
kubectl get deployments --server=https://172.31.25.106:6443  --token=$TOKEN --insecure-skip-tls-verify
# Example => Public IP ✅
kubectl get deployments --server=https://16.171.116.129:6443  --token=$TOKEN --insecure-skip-tls-verify
```

### 5. **Create Kubeconfig File**

```yaml
apiVersion: v1
kind: Config
clusters:
  - name: kubernetes-cluster
    cluster:
      server: https://<api-server-endpoint>:6443
      certificate-authority-data: <Base64-encoded-ca.crt>
contexts:
  - name: jenkins-context
    context:
      cluster: kubernetes-cluster
      namespace: default
      user: jenkins
current-context: jenkins-context
users:
  - name: jenkins
    user:
      token: <token>
```

Replace the placeholders:

- **`<api-server-endpoint>`**: The Kubernetes API server endpoint.
- **`<Base64-encoded-ca.crt>`**: The Base64-encoded CA certificate.
- **`<token>`**: The token generated for the service account.

## Best Practices

- **Limit Permissions**: Only grant the permissions necessary for the service account to perform its tasks. Avoid using broad permissions like `cluster-admin` unless absolutely necessary.
- **Namespace Isolation**: Use separate service accounts for different namespaces to maintain isolation.
- **Rotate Tokens**: Regularly rotate service account tokens to maintain security.

## Summary

Service accounts in Kubernetes provide a secure and manageable way for processes running in pods to interact with the Kubernetes API. By creating service accounts, binding them to specific roles, and using them in your pods, you can enforce fine-grained access control, ensuring that your applications have only the permissions they need. This enhances security, maintains isolation, and ensures that API interactions are auditable and traceable.
