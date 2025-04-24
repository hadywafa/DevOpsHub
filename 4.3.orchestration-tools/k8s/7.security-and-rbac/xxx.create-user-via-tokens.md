# Accessing the Kubernetes API Server Using a Static Token File

## Step 1: Create the Static Token File

1. **Create the Token File**:

   - Create a file named `tokens.csv` in a secure location on the master node.

   ```bash
   sudo nano /etc/kubernetes/tokens.csv
   ```

2. **Add Token Information**:

   - Add a line to the file in the format `<token>,<username>,<userid>,<group>`.
   - Example:

   ```plaintext
   abcdef1234567890,hady,uid123,system:masters
   ```

   - **`token`**: A unique string used for authentication.
   - **`username`**: The user's name.
   - **`userid`**: A unique identifier for the user.
   - **`group`**: The group the user belongs to, such as `system:masters` for cluster-admin privileges.

3. **Save and Close** the file.

## Step 2: Configure the API Server to Use the Static Token File

1. **Edit the API Server Manifest**:

   - Open the API server manifest file located at `/etc/kubernetes/manifests/kube-apiserver.yaml`.

   ```bash
   sudo nano /etc/kubernetes/manifests/kube-apiserver.yaml
   ```

2. **Add the Token File Argument**:

   - Find the `spec.containers.args` section and add:

   ```yaml
   - --token-auth-file=/etc/kubernetes/tokens.csv
   ```

   - Example section:

   ```yaml
   containers:
     - name: kube-apiserver
       image: k8s.gcr.io/kube-apiserver:v1.30.4
       command:
         - kube-apiserver
       args:
         - --advertise-address=192.168.0.1
         - --allow-privileged=true
         - --authorization-mode=Node,RBAC
         - --token-auth-file=/etc/kubernetes/tokens.csv
   ```

3. **Save and Close** the file.

   - The API server will automatically restart because it’s managed by `kubelet`. Monitor the restart process:

   ```bash
   kubectl get pods -n kube-system -w
   ```

## Step 3: Use the Token to Access the API Server

### Option A: Using `kubectl` with the Token Directly

1. **Access the API server** using the token:

   ```bash
   kubectl --token=abcdef1234567890 get pods -A
   ```

   - Replace `abcdef1234567890` with your actual token.

### Option B: Create a kubeconfig File for Easier Access

1. **Create a kubeconfig File**:

   ```yaml
   apiVersion: v1
   kind: Config
   clusters:
     - name: kubernetes-cluster
       cluster:
         server: https://<api-server-endpoint>:6443
         certificate-authority: /etc/kubernetes/pki/ca.crt
   contexts:
     - name: hady-context
       context:
         cluster: kubernetes-cluster
         user: hady
   current-context: hady-context
   users:
     - name: hady
       user:
         token: abcdef1234567890
   ```

   - Replace `<api-server-endpoint>` with your API server's address.
   - Replace `abcdef1234567890` with your actual token.

2. **Use the Kubeconfig File**:

   - Specify the kubeconfig file in your commands:

   ```bash
   kubectl --kubeconfig=/path/to/your/kubeconfig.yaml get nodes
   ```

   - Or set it as the default configuration:

   ```bash
   export KUBECONFIG=/path/to/your/kubeconfig.yaml
   ```

## Step 4: Verify Access and Security Considerations

1. **Verify Access**:

   - Test your setup by running a few `kubectl` commands:

   ```bash
   kubectl get nodes
   kubectl get pods -A
   ```

2. **Security Considerations**:
   - **Token Security**: Ensure the token is stored securely as it provides access to your cluster.
   - **Limited Use**: Static tokens are better suited for testing and should not be used in production.
   - **Monitor Usage**: Regularly audit and monitor access to the API server to ensure tokens are being used appropriately.

---

By following these steps, you can securely access your Kubernetes API server using a static token file, making it easy to authenticate and manage your cluster.
