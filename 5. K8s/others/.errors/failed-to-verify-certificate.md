# Common Error in K8s

## Failed to verify Certificate

The error message you're encountering indicates that the Kubernetes API server's TLS certificate is not valid for the IP address `16.171.116.129`. The certificate is valid for internal cluster IPs (`10.96.0.1`, `172.31.25.106`), but not for the public IP (`16.171.116.129`). This typically happens when the API server's certificate does not include the public IP in its Subject Alternative Name (SAN) list.

To resolve this issue, you have a few options:

### Option 1: Use the `--insecure-skip-tls-verify` Flag

You can bypass the TLS certificate verification for quick testing purposes by using the `--insecure-skip-tls-verify` flag:

```bash
kubectl get deployments --server=https://16.171.116.129:6443 --token=$TOKEN --insecure-skip-tls-verify
```

**Note**: This method is not recommended for production environments because it bypasses certificate validation and makes the connection less secure.

### Option 2: Regenerate the API Server Certificate with the Public IP

A more secure and proper solution is to regenerate the Kubernetes API server's certificate to include the public IP (`16.171.116.129`) in the SANs. Here's how you can do it:

#### Step 1: Modify the API Server Configuration

1. Edit the kube-apiserver manifest, typically found at `/etc/kubernetes/manifests/kube-apiserver.yaml` on the control plane node.

2. Add the public IP address (`16.171.116.129`) to the `--apiserver-cert-extra-sans` argument:

   ```yaml
   - --apiserver-cert-extra-sans=16.171.116.129,10.96.0.1,172.31.25.106
   ```

3. Save the changes.

#### Step 2: Regenerate the API Server Certificates

If you're using `kubeadm`, regenerate the certificates with the updated SANs:

```bash
sudo kubeadm init phase certs apiserver --apiserver-cert-extra-sans=16.171.116.129
```

Alternatively, you can regenerate all certificates:

```bash
sudo kubeadm init phase certs all --apiserver-cert-extra-sans=16.171.116.129
```

#### Step 3: Restart the Kubelet Service

After regenerating the certificates, restart the kubelet to apply the new certificate:

```bash
sudo systemctl restart kubelet
```

#### Step 4: Verify the New Certificate

You can verify that the API server's certificate includes the public IP by using `openssl`:

```bash
openssl s_client -connect 16.171.116.129:6443 -servername 16.171.116.129 < /dev/null 2>/dev/null | openssl x509 -noout -text | grep -A1 "Subject Alternative Name"
```

### Option 3: Use a Load Balancer or DNS Name

If your setup allows, consider using a load balancer with a DNS name that is included in the API server's certificate. This approach avoids having to deal with changing IP addresses and certificates.

- Ensure the DNS name is included in the `--apiserver-cert-extra-sans` argument.
- Access the API server using the DNS name instead of the IP address.

### Summary

- **Quick Fix**: Use `--insecure-skip-tls-verify` to bypass certificate validation (not recommended for production).
- **Proper Fix**: Regenerate the API server's certificate to include the public IP (`16.171.116.129`) in the SANs.
- **Alternative**: Use a load balancer or DNS name that is already included in the certificate's SANs.

These steps should help you resolve the TLS certificate verification issue and securely connect to your Kubernetes API server.
