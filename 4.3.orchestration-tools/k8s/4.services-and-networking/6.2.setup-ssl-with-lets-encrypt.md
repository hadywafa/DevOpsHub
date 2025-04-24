# Generate a TLS (SSL) certificate for your domain (`hadywafa.com`) and its subdomains

Here is a step-by-step guide to **generate a TLS (SSL) certificate for your domain (`hadywafa.com`) and its subdomains** using **Certbot** and **Let's Encrypt**.

## Prerequisites:

1. You have access to your domain's DNS settings (e.g., through Namecheap).
2. You have **Certbot** installed on your server.
3. You have root or sudo access to your server.

## Step-by-Step Process to Generate TLS for Domain and Subdomains

## Step 1: Install Certbot (If Not Installed)

Make sure **Certbot** is installed. If not, you can install it using the following command:

### For Ubuntu/Debian:

```bash
sudo apt update
sudo apt install certbot
```

For other operating systems, follow the instructions [here](https://certbot.eff.org/instructions).

---

## Step 2: Request a Wildcard Certificate

The next step is to generate a **wildcard certificate** for your domain (`*.hadywafa.com`) and the root domain (`hadywafa.com`). Since wildcard certificates require DNS validation, we will be adding a **DNS TXT record** to prove ownership of the domain.

Run the following command:

```bash
sudo certbot certonly --manual --preferred-challenges=dns -d hadywafa.com -d "*.hadywafa.com"
```

This command does the following:

- **certonly**: Only generates the certificate without trying to modify the web server configuration.
- **--manual**: Requires manual DNS validation.
- **--preferred-challenges=dns**: Uses DNS validation (required for wildcard certificates).
- **-d hadywafa.com -d "\*.hadywafa.com"**: Specifies both the root domain and wildcard subdomain.

## Step 3: Add the DNS TXT Record for Validation

After running the command above, Certbot will prompt you to add a **DNS TXT record** to your DNS provider (e.g., Namecheap). The output will look something like this:

```ini
Please deploy a DNS TXT record under the name:

_acme-challenge.hadywafa.com.

with the following value:

8rMB0swwy8OwjqyQrVzGzjJVPFL2ttWyYc4IF0XVGUE
```

### To add the TXT record in Namecheap:

1. **Log into your Namecheap account**.
2. Navigate to **Domain List** and click **Manage** next to your domain (`hadywafa.com`).
3. Go to the **Advanced DNS** tab.
4. Under **Host Records**, click **Add New Record** and choose **TXT Record**.
5. Enter the following details:
   - **Type**: TXT Record
   - **Host**: `_acme-challenge`
   - **Value**: The value provided by Certbot (e.g., `8rMB0swwy8OwjqyQrVzGzjJVPFL2ttWyYc4IF0XVGUE`)
   - **TTL**: Automatic

It should look something like this:

```ini
Type        Host                Value                                        TTL
TXT         _acme-challenge      8rMB0swwy8OwjqyQrVzGzjJVPFL2ttWyYc4IF0XVGUE  Automatic
```

6. Save the DNS record.

## Step 4: Wait for DNS Propagation

After adding the DNS record, you will need to wait a few minutes for the changes to propagate. You can verify that the DNS TXT record is visible using tools like [Google Admin Toolbox Dig](https://toolbox.googleapps.com/apps/dig/#TXT/_acme-challenge.hadywafa.com).

Once you see the record propagated, return to your terminal and press **Enter** to let Certbot continue the process.

---

## Step 5: Certbot Completes Validation

Once Certbot verifies the DNS record, it will generate the wildcard certificate for `hadywafa.com` and `*.hadywafa.com`.

Certbot will store your new certificate files in the following directory by default:

```ini
/etc/letsencrypt/live/hadywafa.com/
```

These files include:

- **fullchain.pem**: The full certificate chain.
- **privkey.pem**: Your private key.

## Step 6: Update NGINX to Use the Wildcard Certificate

Now, you need to configure **NGINX** to use the newly generated certificate. Here’s how you can configure NGINX for both `hadywafa.com` and `*.hadywafa.com`:

Edit your **NGINX configuration** file (e.g., `/etc/nginx/sites-available/hadywafa`):

```nginx
# HTTPS Server Block
server {
    listen 443 ssl;
    server_name hadywafa.com *.hadywafa.com;

    ssl_certificate /etc/letsencrypt/live/hadywafa.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/hadywafa.com/privkey.pem;

    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;

    location / {
        proxy_pass https://k8s_https;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    access_log /var/log/nginx/access.log;
    error_log /var/log/nginx/error.log;
}

# Optional HTTP to HTTPS redirect
server {
    listen 80;
    server_name hadywafa.com *.hadywafa.com;

    location / {
        return 301 https://$host$request_uri;  # Redirect HTTP to HTTPS
    }
}
```

## Step 7: Test and Restart NGINX

1. **Test the NGINX configuration** to ensure everything is correct:

   ```bash
   sudo nginx -t
   ```

2. **Restart NGINX** to apply the new configuration:

   ```bash
   sudo systemctl restart nginx
   ```

## Step 8: Verify SSL Setup

Now that the certificate is installed, verify that the SSL certificate is working for both `hadywafa.com` and its subdomains (e.g., `api.hadywafa.com`).

You can check the SSL status using [SSL Labs](https://www.ssllabs.com/ssltest/) to ensure everything is working correctly.

## Configure NGINX to Use the New Certificate

We will configure NGINX to distribute HTTP and HTTPS traffic across your Kubernetes worker nodes.

### 1. **Create a new NGINX configuration file**:

```bash
sudo nano /etc/nginx/sites-available/hadywafa
```

### 2. **Add the following configuration** to load balance traffic between the worker nodes (`192.168.1.51` and `192.168.1.52`) for both HTTP and HTTPS

```nginx
# Upstream configuration for HTTP traffic
upstream k8s_http {
    server 192.168.1.51:32680;  # Worker Node 1 HTTP NodePort
    server 192.168.1.52:32680;  # Worker Node 2 HTTP NodePort
    keepalive 32;
}

# Upstream configuration for HTTPS traffic
upstream k8s_https {
    server 192.168.1.51:31064;  # Worker Node 1 HTTPS NodePort
    server 192.168.1.52:31064;  # Worker Node 2 HTTPS NodePort
    keepalive 32;
}

# HTTP Server Block
server {
    listen 80;
    server_name *.hadywafa.com;

    location / {
        proxy_pass http://k8s_http;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    access_log /var/log/nginx/access.log upstreamlog;
    error_log /var/log/nginx/error.log;
}

# HTTPS Server Block
server {
    listen 443 ssl;
    server_name *.hadywafa.com;

    ssl_certificate /etc/letsencrypt/live/hadywafa.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/hadywafa.com/privkey.pem;

    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;

    location / {
        proxy_pass https://k8s_https;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    access_log /var/log/nginx/access.log upstreamlog;
    error_log /var/log/nginx/error.log;
}
```

### 3. **Link the configuration** to enable it:

```bash
sudo ln -s /etc/nginx/sites-available/hadywafa /etc/nginx/sites-enabled/
```

### 4. **Test the NGINX configuration** for syntax errors:

```bash
sudo nginx -t
```

### 5. **Reload NGINX** to apply the changes:

```bash
sudo systemctl reload nginx
```

## Summary

1. **Run Certbot** with the wildcard certificate option.
2. **Add the DNS TXT record** for `_acme-challenge.hadywafa.com` in your DNS provider.
3. **Verify DNS propagation**.
4. **Certbot generates the certificate** for both `hadywafa.com` and `*.hadywafa.com`.
5. **Update NGINX** to use the new certificate.
6. **Test and restart NGINX** to apply the changes.

This setup will now automatically cover `hadywafa.com` and all subdomains under `*.hadywafa.com`.

Let me know if you need further assistance!
