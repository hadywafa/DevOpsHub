import json
import os
import socket
import time
from datetime import datetime, timezone
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from urllib.parse import parse_qs, urlparse


APP_NAME = os.getenv("APP_NAME", "echo-app")
APP_COLOR = os.getenv("APP_COLOR", "gray")
APP_PORT = int(os.getenv("APP_PORT", "8000"))
HOSTNAME = socket.gethostname()


class Handler(BaseHTTPRequestHandler):
    server_version = "EchoLab/1.0"

    def _json(self, status_code, payload, extra_headers=None):
        body = json.dumps(payload, indent=2).encode("utf-8")
        self.send_response(status_code)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(body)))
        self.send_header("X-App-Name", APP_NAME)
        self.send_header("X-App-Color", APP_COLOR)
        if extra_headers:
            for key, value in extra_headers.items():
                self.send_header(key, value)
        self.end_headers()
        self.wfile.write(body)

    def log_message(self, fmt, *args):
        print(f"{self.address_string()} - {fmt % args}")

    def do_GET(self):
        parsed = urlparse(self.path)
        query = parse_qs(parsed.query)

        if parsed.path == "/healthz":
            self._json(200, {"status": "ok", "app": APP_NAME})
            return

        if parsed.path.startswith("/slow"):
            seconds = min(float(query.get("seconds", ["2"])[0]), 15)
            time.sleep(seconds)

        if parsed.path.startswith("/status/"):
            try:
                code = int(parsed.path.rsplit("/", 1)[-1])
            except ValueError:
                code = 400
            self._json(code, {"forced_status": code, "app": APP_NAME})
            return

        payload = {
            "app": APP_NAME,
            "color": APP_COLOR,
            "hostname": HOSTNAME,
            "method": self.command,
            "path": parsed.path,
            "query": query,
            "client_address": self.client_address[0],
            "timestamp_utc": datetime.now(timezone.utc).isoformat(),
            "headers": {key: value for key, value in self.headers.items()},
        }
        self._json(200, payload)


if __name__ == "__main__":
    server = ThreadingHTTPServer(("0.0.0.0", APP_PORT), Handler)
    print(f"Starting {APP_NAME} on 0.0.0.0:{APP_PORT}")
    server.serve_forever()
