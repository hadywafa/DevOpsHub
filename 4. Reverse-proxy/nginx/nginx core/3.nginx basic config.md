
# Nginx Basic Configuration

#nginx
## Important Configuration Directory & Files


![[Pasted image 20260330224306.png]]

![[Pasted image 20260330224539.png]]


## Structure of `nginx.conf`

### Global Settings

> Set up configuration that affect the entire nginx server

- user privileges
- number of worker processes
- rate limiting settings

```nginx
# specefy the user that nginx run as.
user www-data;

# define number of worker processes
# auto settings let nginx adjust the number to match available CPU cores.
worker_processes auto; 

# specefy the PID file location for the nginx master process
pid /run/nginx.pid;
```
### Event Blocks

> Managing connections and threading

- worker connections
- event model

```nginx
events {
	worker_connections 1024;
	use kqueue;
}
```

### Http Block

> Handles everything related to web traffic
> Contains server blocks (like virtual hosts) and settings for http optimizations and security

```nginx
http {
	sendfile on;
	tcp_nopush on;
	keepalive_timeout 65;
	types_hash_max_size 2048;
	
	include /etc/nginx/mime.types;
	default_type application/octet-stream;
	
	include /etc/nginx/conf.d/*.conf;
	include /etc/nginx/sites-enabled/*;
}
```

### Server Block

> Defines how nginx handles requests for different domains or subdomains.


```nginx
server {
	listen 80;
	server_name example.com www.example.com;
	
	root /var/www/example.com/html;
	index index.html;
	
	location / {
		try_files $uri $uri/ =404;
	}
}
```

## Nginx Commands

```bash title:nginx
# Checks the nginx version
nginx -v

# Provides detailed build and config info, including modules
nginx -V
```

```bash title:nginx
# Checks the Nginx configuration for any issues
nginx -t

# Sharing config when seeking support
nginx -T
```

```bash title:nginx
# Sends signals to Nginx master process
nginx -s


nginx -s stop
nginx -s quit
nginx -s reopen
nginx -s reload # just reload the config
```