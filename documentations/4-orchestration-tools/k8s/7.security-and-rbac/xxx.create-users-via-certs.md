# Users, Groups and Service Account in k8s

In Kubernetes, user and group management is typically handled externally and not directly managed by the Kubernetes API. This is because Kubernetes does not have a built-in user management system. Instead, it relies on external identity providers for authentication. Here’s how you can manage users and groups and integrate them with Kubernetes.

## Creating Users

To create users in Kubernetes, you typically use one of the following methods:

1. **Client Certificate Authentication**:

   - Generate a client certificate for each user.
   - Configure the Kubernetes API server to trust the Certificate Authority (CA) that issued the client certificates.

2. **Static Token File**:

   - Use a static token file to manage users.
   - Define tokens for each user in a file and configure the API server to use this file.

3. **External Identity Providers**:
   - Use external systems like LDAP, Active Directory, or OAuth2 to manage user authentication.
   - Integrate these systems with Kubernetes through an Identity Provider (IdP).

## Client Certificate Authentication

`User Must be inside the cluster to communicate with the API server`

![alt text](images/client-cert-1.png)

1. **Generate key-pair for user using openssl**: `openssl genrsa -out hady.key 2048`
2. **Generate CSR**: `openssl req -new -key hady.key -subj "/CN=hady/O=dev-group" -out hady.csr`
3. **Send CSR using k8s Certificates API**: create a certification request yaml file and send it to k8s.
4. **K8s Signs Certificates for you**: by default, k8s will sign the certificate for 1 year
5. **K8s admin approves certificate**: `kubectl certificate approve hady`

### 1. **Generate a Key Pair for the User**

First, you'll generate a private key for the user "hady" using OpenSSL.

```bash
openssl genrsa -out hady.key 2048
```

- **`hady.key`**: This is the private key that will be used to generate the CSR and later to establish a secure connection with the Kubernetes API server.

### 2. **Generate a Certificate Signing Request (CSR)**

Next, create a CSR using the private key. This CSR will be submitted to Kubernetes for signing.

```bash
openssl req -new -key hady.key -subj "/CN=hady/O=dev-group" -out hady.csr
```

- **`/CN=hady`**: The Common Name (CN) field represents the username in Kubernetes.
- **`/O=dev-group`**: The Organization (O) field is typically used for group membership in Kubernetes.
- **`hady.csr`**: This is the CSR file that you'll submit to Kubernetes.

### 3. **Create a [Certificate Signing Request](https://kubernetes.io/docs/reference/access-authn-authz/certificate-signing-requests/) (CSR) in Kubernetes**

Create a Kubernetes CSR resource by writing a YAML file that includes the Base64-encoded CSR. This CSR will request that Kubernetes signs the certificate.

#### **Example CSR YAML File (`hady-csr.yaml`)**:

```yaml
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: hady
spec:
  groups:
    - system:authenticated
  request: <Base64-encoded-hady.csr>
  signerName: kubernetes.io/kube-apiserver-client
  usages:
    - client auth
```

- **`metadata.name`**: The name of the CSR resource in Kubernetes, here set to "hady".
- **`groups`**: The group that the user belongs to, which will be "system:authenticated" by default.
- **`request`**: The Base64-encoded CSR from the previous step.
- **`signerName`**: Specifies the signer, which is typically `kubernetes.io/kube-apiserver-client` for client authentication certificates.
- **`usages`**: Specifies that this certificate will be used for client authentication.

#### **Command to Encode the CSR**

You can encode the CSR directly in your terminal and insert it into the YAML file:

```bash
cat hady.csr | base64 | tr -d '\n'
```

Replace the <Base64-encoded-hady.crt> placeholder in the YAML file with the actual Base64-encoded string.

#### **Apply the CSR to Kubernetes**:

Once the YAML file is ready, apply it to the Kubernetes cluster:

```bash
kubectl apply -f hady-csr.yaml
```

### 4. **Kubernetes Signs the Certificate**

By default, Kubernetes will automatically sign the CSR once it's approved. The certificate is typically valid for one year unless otherwise configured.

### 5. **Kubernetes Admin Approves the Certificate**

After submitting the CSR, a Kubernetes administrator (or the appropriate user with the right permissions) must approve the certificate:

```bash
kubectl get csr
kubectl certificate approve hady
```

- **`hady`**: This is the name of the CSR you submitted (as defined in the `metadata.name` field of the YAML file).

### 6. **Retrieve the Signed Certificate**

Once the CSR is approved, you can retrieve the signed certificate and save it to a file:

```bash
kubectl get csr hady -o jsonpath='{.status.certificate}' | base64 --decode > hady.crt
```

- **`hady.crt`**: This file contains the signed certificate that you can use in your kubeconfig file.

### 3. **Assign Permissions to the Service Account**

Once the service account is created, you need to assign permissions by binding it to a `Role` or `ClusterRole`. This is done using a `RoleBinding` or `ClusterRoleBinding`.

**Role:**

```bash
kubectl create role pod-read-dev-role \
--verb=get,watch,list \
--resource=pods \
--dry-run=client -o yaml > pod-read-dev-role.yaml
```

```yaml
# pod-read-dev-role.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: pod-read-dev-role
  namespace: dev
rules:
  - apiGroups: [""]
    resources: ["pods"]
    verbs: ["get", "watch", "list"]
```

```bash
kubectl apply -f pod-read-dev-role.yaml
```

**RoleBinding:**

```bash
kubectl create rolebinding bind-pod-read-dev-role-to-hady \
--role=pod-read-dev-role \
--user=hady \
--namespace=dev \
--dry-run=client -o yaml > bind-pod-read-dev-role-to-hady.yaml
```

```yaml
# bind-pod-read-dev-role-to-hady.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: bind-pod-read-dev-role-to-hady
  namespace: dev
subjects:
  - kind: User
    name: "hady"
    apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role
  name: pod-read-dev-role
  apiGroup: rbac.authorization.k8s.io
```

```bash
kubectl apply -f bind-pod-read-dev-role-to-hady.yaml
```

### 7. **Test the Certificate**

You can test the certificate by using it to authenticate with the Kubernetes API server:

```bash
kubectl get pods --server=https://<api-server-endpoint>:6443 \
--certificate-authority=/etc/kubernetes/pki/ca.crt  \
--client-key=hady.key \
--client-certificate=hady.crt \
--insecure-skip-tls-verify
```

### 8. **Create a kubeconfig File**

With the signed certificate (`hady.crt`), the private key (`hady.key`), and the CA certificate (already available from your cluster setup), you can now create a kubeconfig file that the user "hady" will use to authenticate with the Kubernetes cluster.

#### **Send kubeconfig to user with external key/pair files**

![alt text](images/send-kubeconfig-to-user-with-external-key-pair-files.png)

```yaml
apiVersion: v1
kind: Config
clusters:
  - name: kubernetes-cluster
    cluster:
      server: https://<api-server-endpoint>:6443
      certificate-authority-data: <Base64-encoded-ca.crt>
contexts:
  - name: hady-context
    context:
      cluster: kubernetes-cluster
      namespace: default
      user: hady
current-context: hady-context
users:
  - name: hady
    user:
      client-certificate: <path-to-hady.crt>
      client-key: <path-to-hady.key>
```

Replace the placeholders:

- **`<api-server-endpoint>`**: The Kubernetes API server endpoint.
- **`<Base64-encoded-ca.crt>`**: The Base64-encoded CA certificate.
- **`<path-to-hady.crt>`**: The path to the `hady.crt` file.
- **`<path-to-hady.key>`**: The path to the `hady.key` file.

#### **Send kubeconfig to user with impeded key/pair**

![alt text](images/send-kubeconfig-to-user-with-impeded-key-pair.png)

```yaml
apiVersion: v1
kind: Config
clusters:
  - name: kubernetes-cluster
    cluster:
      server: https://<api-server-endpoint>:6443
      certificate-authority-data: <Base64-encoded-ca.crt>
contexts:
  - name: hady-context
    context:
      cluster: kubernetes-cluster
      namespace: default
      user: hady
current-context: hady-context
users:
  - name: hady
    user:
      client-certificate-data: <Base64-encoded-hady.crt>
      client-key-data: <Base64-encoded-hady.key>
```

Replace the placeholders:

- **`<api-server-endpoint>`**: The Kubernetes API server endpoint (public IP or domain name).
- **`<Base64-encoded-ca.crt>`**: The Base64-encoded CA certificate.
- **`<Base64-encoded-hady.crt>`**: The Base64-encoded `hady.crt` file.
- **`<Base64-encoded-hady.key>`**: The Base64-encoded `hady.key` file.

```bash
# Encode the ca.crt
cat /etc/kubernetes/pki/ca.crt | base64 | tr -d '\n'
# Encode the hady.crt
cat hady.crt | base64 | tr -d '\n'
# Encode the hady.key
cat hady.key | base64 | tr -d '\n'
```

## Summary

- **Users**: Managed externally (e.g., client certificates, static token files, external identity providers).
- **Groups**: Defined within client certificates or external identity providers.
- **RoleBindings and ClusterRoleBindings**: Used to assign permissions to users and groups within Kubernetes.

Once users and groups are set up, you can create RoleBindings and ClusterRoleBindings to manage permissions.
