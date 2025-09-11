# 🔐 SSL/TLS and HTTPS setup across environments.

## ✅ **1. Foundations of SSL/TLS & HTTPS**

Start here to understand the core mechanics:

- What is SSL vs TLS (TLS is the modern, secure protocol)
- How HTTPS works (TLS over HTTP)
- TLS handshake process
- Cipher suites and encryption algorithms
- Certificate types: DV, OV, EV
- TLS versions: Only use TLS 1.2 and 1.3

---

## 🔧 **2. Certificate Management**

Learn how certificates are issued, validated, and chained:

- Public Key Infrastructure (PKI)
- Certificate Authority (CA) roles
- Certificate chain: server → intermediate → root
- PEM, CRT, CER formats
- Certificate bundles and fullchain.pem

---

## 🧪 **3. Self-Signed Certificates**

For dev/test environments:

- Generate with `openssl` or `mkcert`
- Trust locally (OS/browser)
- Understand limitations (no CA validation)

---

## 🆓 **4. Automated Certificates with Let’s Encrypt**

For public domains:

- Use `certbot` or `acme.sh`
- HTTP vs DNS challenge
- Auto-renewal setup
- Integration with Nginx, Apache, Kubernetes

---

## 🌐 **5. Web Server Configuration**

Apply certs to actual servers:

- **Nginx**: `ssl_certificate`, `ssl_certificate_key`, TLS settings
- **Apache**: `SSLCertificateFile`, `SSLCertificateKeyFile`
- TLS hardening: disable weak ciphers, enable TLS 1.3

---

## ☁️ **6. Cloud Platforms**

Master SSL/TLS in cloud-native environments:

### 🔹 Azure

- Azure App Service: free certs, custom bindings
- Azure Key Vault: store/manage certs securely
- Azure Front Door: global HTTPS termination

### 🔹 AWS

- AWS Certificate Manager (ACM): free certs, auto-renewal
- ELB/ALB integration
- Manual setup on EC2 with Nginx/Apache

---

## 📦 **7. Kubernetes (K8s)**

Secure containerized apps:

- Use `cert-manager` for automated certs
- TLS secrets and Ingress configuration
- Internal mTLS between services (Istio, Linkerd)

---

## 🔐 **8. Advanced TLS Topics**

For enterprise-grade security:

- Mutual TLS (mTLS): client cert verification
- Certificate pinning: prevent MITM
- TLS offloading via proxies/load balancers
- TLS in service mesh architectures
