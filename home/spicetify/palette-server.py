#!/usr/bin/env python3

import json
import os

from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path


HOST = "127.0.0.1"
PORT = 47943

CACHE = Path(
    os.environ.get(
        "XDG_CACHE_HOME",
        str(Path.home() / ".cache"),
    )
)

PALETTE = CACHE / "43pr/palette.json"

COLOR_KEYS = (
    "bg",
    "bg_panel",
    "bg_track",
    "bg_hover",
    "fg",
    "fg_dim",
    "accent",
    "border",
    "border_strong",
    "danger",
)


class PaletteHandler(BaseHTTPRequestHandler):

    def cors_headers(self):
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Access-Control-Allow-Methods", "GET, OPTIONS")
        self.send_header("Access-Control-Allow-Private-Network", "true")

    def do_OPTIONS(self):
        self.send_response(204)
        self.cors_headers()
        self.end_headers()

    def do_GET(self):
        if self.path != "/palette":
            self.send_error(404)
            return

        try:
            palette = json.loads(
                PALETTE.read_text(encoding="utf-8")
            )

            colors = {
                key: palette[key]
                for key in COLOR_KEYS
                if isinstance(palette.get(key), str)
            }

            body = json.dumps(colors).encode("utf-8")

        except (OSError, ValueError):
            self.send_error(503, "Palette unavailable")
            return

        self.send_response(200)
        self.cors_headers()

        self.send_header(
            "Content-Type",
            "application/json; charset=utf-8",
        )
        self.send_header("Cache-Control", "no-store")
        self.send_header("Content-Length", str(len(body)))

        self.end_headers()
        self.wfile.write(body)

    def log_message(self, *args):
        pass


if __name__ == "__main__":
    print(
        f"43PR Spotify palette server: http://{HOST}:{PORT}/palette",
        flush=True,
    )

    ThreadingHTTPServer(
        (HOST, PORT),
        PaletteHandler,
    ).serve_forever()
