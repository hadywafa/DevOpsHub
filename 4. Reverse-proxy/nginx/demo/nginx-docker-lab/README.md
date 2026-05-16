# Nginx Docker Lab

This is a self-contained Nginx playground built with Docker Compose so you can learn by changing real config and testing it locally.

## What this project covers

- Reverse proxy to one backend
- Load balancing across multiple backends
- Static file serving
- `try_files` and SPA-style fallback
- Redirects and rewrites
- Custom error pages
- Gzip compression
- Basic auth
- Rate limiting
- Proxy caching
- HTTPS with a self-signed certificate
- Nginx status endpoint
- Security headers

## Project structure

```text
nginx-docker-lab/
├─ docker-compose.yml
├─ apps/echo/
│  ├─ Dockerfile
│  └─ app.py
└─ nginx/
   ├─ nginx.conf
   ├─ conf.d/
   │  ├─ 00-upstreams.conf
   │  ├─ 10-http.conf
   │  ├─ 20-https.conf
   │  └─ snippets/
   │     ├─ common-locations.conf
   │     └─ proxy-common.conf
   ├─ html/
   └─ runtime/
```

## Run it

```bash
docker compose up --build
```

Then open:

- `http://localhost:8080`
- `https://localhost:8443`

For basic auth:

- username: `student`
- password: `nginx123`

## Endpoints to test

- `/` main landing page
- `/app1/` direct proxy to backend 1
- `/app2/` direct proxy to backend 2
- `/api/` load-balanced upstream
- `/cache/` cached upstream response
- `/rate/` rate-limited upstream
- `/basic/` protected route with basic auth
- `/healthz` health endpoint from Nginx
- `/status` Nginx stub status
- `/old-docs` 301 redirect example
- `/rewrite-demo/headers` internal rewrite example

## Suggested exercises

1. Refresh `/api/` several times and watch the response switch between `app1` and `app2`.
2. Open `/cache/` twice and compare the `X-Cache-Status` header values.
3. Hit `/rate/` repeatedly with a browser refresh or a loop and watch rate limiting kick in.
4. Open `/basic/` and test authentication.
5. Visit `/missing-page` to see the custom `404.html`.
6. Try `https://localhost:8443` and inspect the TLS configuration in `20-https.conf`.
7. Change the upstream algorithm in `00-upstreams.conf` from `least_conn` to another strategy and test again.
8. Edit timeout, cache, or header settings in `snippets/proxy-common.conf` and reload the stack.

## Useful commands

```bash
docker compose ps
docker compose logs -f nginx
docker compose exec nginx nginx -t
docker compose exec nginx nginx -s reload
docker compose down
```

## Important files to study

- `nginx/nginx.conf`: global settings, gzip, logs, cache zone, rate-limit zones
- `nginx/conf.d/00-upstreams.conf`: upstream pool
- `nginx/conf.d/10-http.conf`: HTTP server
- `nginx/conf.d/20-https.conf`: HTTPS server
- `nginx/conf.d/snippets/common-locations.conf`: routing examples
- `nginx/conf.d/snippets/proxy-common.conf`: shared proxy headers and timeouts

## Notes

- The TLS certificate is self-signed and generated automatically by the `setup` service.
- The `/status` endpoint is open to all clients for learning purposes. Lock it down before using anything similar in a real environment.
- This lab covers many of the most useful Nginx options, but Nginx has more advanced modules and patterns you can add later, like stream proxying, geo-based rules, real IP handling, or WebSocket-heavy setups.
