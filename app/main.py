import json
import os
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

APP_VERSION = os.getenv("APP_VERSION", "dev")


class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path == "/health":
            status = 200
            payload = {"status": "ok"}
        elif self.path == "/":
            status = 200
            payload = {
                "message": "Welcome to the LearnIT DevOps project!",
                "version": APP_VERSION,
            }
        else:
            status = 404
            payload = {"error": "Not found"}

        body = json.dumps(payload).encode("utf-8")
        self.send_response(status)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)


if __name__ == "__main__":
    server = ThreadingHTTPServer(("0.0.0.0", 8000), Handler)
    print("Application listening on port 8000", flush=True)
    server.serve_forever()
