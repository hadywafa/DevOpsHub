# NGINX

#nginx
## Definition

[NGINX](https://nginx.org/) is a high-performance, open-source `web server` (for _static content_) and `reverse proxy` (for **dynamic content**). It is known for its efficiency, scalability, and ability to handle concurrent connections efficiently. Originally designed to address the C10k problem (supporting thousands of concurrent connections), NGINX has evolved into a versatile solution for various web serving and proxying needs.

## Key Features

- **Web Server:** NGINX can serve **static content** directly and act as a reverse proxy for dynamic content, enhancing web server performance.

- **Reverse Proxy:** NGINX can act as a reverse proxy, forwarding requests to other servers and returning the responses to clients. This is often used to improve security, load balance, and cache content.

- **Load Balancer:** NGINX can distribute incoming network traffic across multiple servers, ensuring optimal resource utilization and improved fault tolerance.

- **HTTP and HTTPS:** NGINX supports both HTTP and HTTPS protocols, providing secure communication over the internet.

- **Efficiency:** NGINX is known for its low resource usage and high performance, making it suitable for serving static content and handling a large number of simultaneous connections.

- **Proxy Caching:** NGINX can cache static content and serve it directly to clients, reducing the load on backend servers and improving response times.

- **Modules and Extensibility:** NGINX is highly extensible through modules, allowing users to add or customize features based on their requirements.

- **Community and Support:** NGINX has a large and active community that contributes to its development and provides support through forums, documentation, and third-party modules.

> NGINX is widely used as a `web server`, `reverse proxy`, and `load balancer` in various deployment scenarios, ranging from small websites to large-scale, high-traffic platforms.

## Comparision

### Traditional

1. Apache
2. IIS

### Modern

1. OpenResty
2. LiteSpeed
3. Caddy
