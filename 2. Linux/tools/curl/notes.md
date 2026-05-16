# Notes

## 📂 `/etc/ssl/certs/ca-certificates.crt` File

**In Linux, `/etc/ssl/certs/ca-certificates.crt` contains a bundle of trusted Certificate Authority (CA) certificates used to verify SSL/TLS connections.**

---

### 🔐 What’s Inside `/etc/ssl/certs/ca-certificates.crt`

This file is a **concatenated list of PEM-encoded CA certificates** that your system trusts for secure communications. It’s used by tools like `curl`, `wget`, `git`, and programming libraries (OpenSSL, Python `requests`, etc.) to validate HTTPS endpoints.

- **Format:** Plain text, PEM format (each certificate starts with `-----BEGIN CERTIFICATE-----`)
- **Purpose:** Acts as a trust store for verifying server certificates
- **Used by:** OpenSSL, GnuTLS, and other TLS clients

---

### 🛠️ How It’s Managed

On Debian-based systems (like Ubuntu), this file is generated from individual `.crt` files in `/usr/share/ca-certificates/` using:

```bash
sudo update-ca-certificates
```

This command:

- Reads enabled certificates from `/etc/ca-certificates.conf`
- Concatenates them into `/etc/ssl/certs/ca-certificates.crt`
- Symlinks individual certs into `/etc/ssl/certs/` for OpenSSL compatibility

---

### 🧪 How to Inspect It

To view the contents:

```bash
cat /etc/ssl/certs/ca-certificates.crt
```

To list all included certificate subjects:

```bash
awk 'BEGIN {RS="-----END CERTIFICATE-----"} /BEGIN CERTIFICATE/ {print $0 "-----END CERTIFICATE-----"}' /etc/ssl/certs/ca-certificates.crt | openssl x509 -noout -subject
```

---

## 🥸 `CertificateVerify` in TLS Handshake Process

Imagine this:

- A server shows you a **padlock** (its certificate with public key).
- You say: “If you really own the **key**, unlock this box I locked with your padlock.”
- The server unlocks it — proving it has the **private key**.

That’s how TLS works: the server proves it owns the private key by **decrypting or signing something** that only the real owner could.

---

### 💡 TLS 1.3 Example: CertificateVerify

Let’s walk through a simplified TLS 1.3 flow:

1. **ClientHello** → Client sends random data and supported cipher suites.
2. **ServerHello** → Server agrees on cipher and sends its own random.
3. **Server sends:**
   - `Certificate` → Contains public key
   - `CertificateVerify` → A **digital signature** over the handshake so far
4. **Client verifies:**
   - Uses the public key from the certificate to check the signature
   - If valid → server owns the private key

---
