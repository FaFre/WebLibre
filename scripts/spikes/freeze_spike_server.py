#!/usr/bin/env python3
"""Local server for the container freeze spikes S1 and S11.

Phase 0 of plans/TAB_LOCK_AND_FREEZE_IMPLEMENTATION_PLAN.md. One test page keeps
every kind of activity S1 asks about running on a one-second beat: fetch, a
shared worker, a service worker (with push), EventSource, WebSocket, a slow
response, keepalive fetches (one from the page, one from a worker that is
terminated right after), beacons, preconnect hints and, with a TURN server, a
WebRTC data channel. The server logs every connection opening and closing, and
once a second one summary line per page tag: what it received and which
streams are still open. After the restriction is installed, the frozen tag
must go silent and its open streams must close; the control tag keeps going.

Stdlib only. On the host:

    python3 scripts/spikes/freeze_spike_server.py
    adb reverse tcp:8080 tcp:8080     # the page and everything it talks to
    adb reverse tcp:8081 tcp:8081     # preconnect target (raw TCP, logs accepts)

WebRTC needs a TURN server on the host's LAN address, which the device reaches
over the network: Gecko skips TURN servers on loopback addresses, so an
`adb reverse` port cannot serve. See --help.

On the device, in the container under test:  http://localhost:8080/?tag=frozen
and in another container, as the control:   http://localhost:8080/?tag=control

Send a push (no payload) to a tag's subscription:  curl 'localhost:8080/sendpush?tag=frozen'
"""

import argparse
import base64
import hashlib
import hmac
import html
import json
import os
import re
import secrets
import select
import socket
import sys
import threading
import time
import urllib.error
import urllib.request
from collections import defaultdict
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from urllib.parse import parse_qs, urlparse

WS_GUID = "258EAFA5-E914-47DA-95CA-C5AB0DC85B11"
DOWNLOAD_BYTES = 2 * 1024 * 1024  # 1 KiB a second: about 34 minutes
HOLD_SECONDS = 600
TURN_URL = "turn:127.0.0.1:3478?transport=tcp"  # set from --turn-host/--turn-port
# The value of this run's storage markers (spike-<tag> cookies): a marker left
# by an earlier run reads as stale, so it cannot make a wrong-storage test pass.
RUN_MARKER = secrets.token_hex(8)


def spike_markers(cookie_header):
    """Only the spike-<tag> markers a Cookie header carries, each named as this
    run's or stale. Cookies are not scoped by port, so the header can hold
    other localhost services' session cookies, which are never shown or logged."""
    markers = []
    for part in (cookie_header or "").split(";"):
        name, _, value = part.strip().partition("=")
        if name.startswith("spike-"):
            markers.append(f"{name} ({'this run' if value == RUN_MARKER else 'stale'})")
    return ", ".join(markers) or "none"

_print_lock = threading.Lock()


def stamp():
    now = time.time()
    return time.strftime("%H:%M:%S", time.localtime(now)) + f".{int(now * 1000) % 1000:03d}"


def log(message):
    with _print_lock:
        print(f"{stamp()}  {message}", flush=True)


class Stats:
    """Per tag: events received this second, and the streams open now."""

    def __init__(self):
        self.lock = threading.Lock()
        self.received = defaultdict(lambda: defaultdict(int))
        self.open = defaultdict(lambda: defaultdict(set))
        self.silent = set()

    def hit(self, tag, kind):
        with self.lock:
            self.received[tag][kind] += 1

    def opened(self, tag, kind, key):
        with self.lock:
            self.open[tag][kind].add(key)

    def closed(self, tag, kind, key):
        with self.lock:
            self.open[tag][kind].discard(key)

    def tick(self):
        with self.lock:
            tags = set(self.received) | set(self.open)
            lines = []
            for tag in sorted(tags):
                got = {k: v for k, v in self.received[tag].items() if v}
                streams = {k: len(v) for k, v in self.open[tag].items() if v}
                if not got and not streams:
                    if tag not in self.silent:
                        self.silent.add(tag)
                        lines.append(f"[{tag}] SILENT: nothing received, no stream open")
                    continue
                self.silent.discard(tag)
                got_text = " ".join(f"{k}={v}" for k, v in sorted(got.items())) or "-"
                open_text = " ".join(f"{k}={v}" for k, v in sorted(streams.items())) or "-"
                lines.append(f"[{tag}] received: {got_text} | open: {open_text}")
            self.received.clear()
        for line in lines:
            log(line)


STATS = Stats()
ENDPOINTS = {}  # tag -> subscription JSON (endpoint, keys)


def b64url_decode(text):
    return base64.urlsafe_b64decode(text + "=" * (-len(text) % 4))


def encrypt_push(subscription, payload):
    """RFC 8291 aes128gcm body for `payload`, or None without keys or `cryptography`."""
    keys = subscription.get("keys") or {}
    if "p256dh" not in keys or "auth" not in keys:
        return None
    try:
        from cryptography.hazmat.primitives.asymmetric import ec
        from cryptography.hazmat.primitives.ciphers.aead import AESGCM
        from cryptography.hazmat.primitives.serialization import Encoding, PublicFormat
    except ImportError:
        return None
    ua_public = b64url_decode(keys["p256dh"])
    auth_secret = b64url_decode(keys["auth"])
    as_private = ec.generate_private_key(ec.SECP256R1())
    as_public = as_private.public_key().public_bytes(Encoding.X962, PublicFormat.UncompressedPoint)
    ua_key = ec.EllipticCurvePublicKey.from_encoded_point(ec.SECP256R1(), ua_public)
    ecdh_secret = as_private.exchange(ec.ECDH(), ua_key)

    def hkdf(salt, ikm, info, length):
        prk = hmac.new(salt, ikm, hashlib.sha256).digest()
        return hmac.new(prk, info + b"\x01", hashlib.sha256).digest()[:length]

    ikm = hkdf(auth_secret, ecdh_secret, b"WebPush: info\x00" + ua_public + as_public, 32)
    salt = os.urandom(16)
    cek = hkdf(salt, ikm, b"Content-Encoding: aes128gcm\x00", 16)
    nonce = hkdf(salt, ikm, b"Content-Encoding: nonce\x00", 12)
    ciphertext = AESGCM(cek).encrypt(nonce, payload + b"\x02", None)
    return salt + (4096).to_bytes(4, "big") + bytes([len(as_public)]) + as_public + ciphertext


def client_gone(sock):
    """True once the peer has closed or reset the connection (without reading data)."""
    try:
        readable, _, _ = select.select([sock], [], [], 0)
        if readable:
            return sock.recv(1, socket.MSG_PEEK) == b""
    except OSError:
        return True
    return False


def ws_frame(text):
    data = text.encode()
    header = bytes([0x81])
    if len(data) < 126:
        header += bytes([len(data)])
    elif len(data) < 65536:
        header += bytes([126]) + len(data).to_bytes(2, "big")
    else:
        header += bytes([127]) + len(data).to_bytes(8, "big")
    return header + data


def ws_parse(buf):
    """(opcode, payload, consumed) for the first whole frame in buf, or None."""
    if len(buf) < 2:
        return None
    opcode, masked, length, i = buf[0] & 0x0F, buf[1] & 0x80, buf[1] & 0x7F, 2
    if length == 126:
        if len(buf) < 4:
            return None
        length, i = int.from_bytes(buf[2:4], "big"), 4
    elif length == 127:
        if len(buf) < 10:
            return None
        length, i = int.from_bytes(buf[2:10], "big"), 10
    mask = b""
    if masked:
        if len(buf) < i + 4:
            return None
        mask, i = buf[i : i + 4], i + 4
    if len(buf) < i + length:
        return None
    payload = buf[i : i + length]
    if masked:
        payload = bytes(b ^ mask[k % 4] for k, b in enumerate(payload))
    return opcode, payload, i + length


class Handler(BaseHTTPRequestHandler):
    protocol_version = "HTTP/1.1"
    server_version = "FreezeSpike/1"

    def log_message(self, format, *args):  # the summary lines replace the access log
        pass

    # Connection bookkeeping: shows Gecko closing pooled connections of a partition.
    def handle(self):
        self.conn_tag = None
        self.conn_requests = 0
        self.port = self.client_address[1]
        try:
            super().handle()
        except (ConnectionResetError, BrokenPipeError):
            pass
        finally:
            if self.conn_tag is not None:
                log(f"[{self.conn_tag}] connection :{self.port} closed after {self.conn_requests} request(s)")

    def params(self):
        query = parse_qs(urlparse(self.path).query)
        tag = re.sub(r"[^a-z0-9-]", "", (query.get("tag", ["untagged"])[0]).lower())[:20] or "untagged"
        src = re.sub(r"[^a-z0-9-]", "", (query.get("src", ["?"])[0]).lower())[:30] or "?"
        return tag, src, query

    def begin(self, tag):
        self.conn_requests += 1
        if self.conn_tag is None:
            self.conn_tag = tag
            log(f"[{tag}] new connection :{self.port}")

    def body(self):
        length = int(self.headers.get("Content-Length") or 0)
        return self.rfile.read(length) if length else b""

    def reply(self, status, content=b"", content_type="text/plain; charset=utf-8", extra=None):
        self.send_response(status)
        self.send_header("Content-Type", content_type)
        self.send_header("Content-Length", str(len(content)))
        self.send_header("Cache-Control", "no-store")
        for key, value in (extra or {}).items():
            self.send_header(key, value)
        self.end_headers()
        if content:
            self.wfile.write(content)

    def do_GET(self):
        tag, src, query = self.params()
        path = urlparse(self.path).path
        if path == "/favicon.ico":
            return self.reply(204)
        if path == "/sendpush":  # from the host, not the page: not counted under the tag
            return self.send_push(tag)
        self.begin(tag)
        if path == "/":
            # The cookie marks this storage: the page a notification opens
            # (/opened) shows which markers it carried, so which storage it ran in.
            return self.reply(
                200, PAGE.replace("@TURN_URL@", TURN_URL).encode(), "text/html; charset=utf-8",
                extra={"Set-Cookie": f"spike-{tag}={RUN_MARKER}; Path=/; Max-Age=86400"})
        if path == "/opened":
            markers = spike_markers(self.headers.get("Cookie"))
            log(f"[{tag}] /opened loaded in a window; storage markers it carried: {markers}")
            STATS.hit(tag, "opened")
            return self.reply(200, OPENED_PAGE.format(tag=html.escape(tag), markers=html.escape(markers)).encode(),
                              "text/html; charset=utf-8")
        if path in SCRIPTS:
            return self.reply(200, SCRIPTS[path].encode(), "text/javascript; charset=utf-8")
        if path == "/ping":
            STATS.hit(tag, src)
            return self.reply(204)
        if path == "/events":
            return self.stream(tag, "sse", lambda n: f"data: {n}\n\n".encode(), "text/event-stream")
        if path == "/slow":
            return self.stream(tag, "slow", lambda n: b".", "text/plain")
        if path == "/download":
            return self.download(tag)
        if path == "/ws":
            return self.websocket(tag)
        if path == "/redirect":
            return self.slow_redirect(tag)
        if path == "/form":
            return self.reply(200, FORM_PAGE.replace("TAG", tag).encode(), "text/html; charset=utf-8")
        if path == "/posted":
            # S12: what waking a slept POST result does. A GET here means the
            # result URL was fetched again without its body.
            log(f"[{tag}] GET /posted: the result page was fetched again WITHOUT its form body")
            return self.reply(200, POSTED_PAGE.format(
                when=stamp(), how="GET (no form body)", body="-").encode(), "text/html; charset=utf-8")
        return self.reply(404, b"not found")

    def do_POST(self):
        tag, src, _ = self.params()
        path = urlparse(self.path).path
        self.begin(tag)
        data = self.body()
        if path == "/beacon":
            log(f"[{tag}] beacon ({src})")
            STATS.hit(tag, f"beacon-{src}")
            return self.reply(204)
        if path == "/endpoint":
            text = data.decode(errors="replace").strip()
            try:
                subscription = json.loads(text)
            except ValueError:
                subscription = {"endpoint": text}
            if ENDPOINTS.get(tag) != subscription:
                keys = "with keys" if (subscription.get("keys") or {}).get("auth") else "without keys"
                log(f"[{tag}] push subscription ({keys}): {subscription.get('endpoint')}")
                log(f"[{tag}]   send a push with: curl 'localhost:{self.server.server_port}/sendpush?tag={tag}'")
            ENDPOINTS[tag] = subscription
            return self.reply(204)
        if path == "/keepalive":
            return self.hold(tag, src)
        if path == "/posted":
            text = data.decode(errors="replace")
            log(f"[{tag}] form POST received: {text[:80]}")
            return self.reply(200, POSTED_PAGE.format(
                when=stamp(), how="POST", body=html.escape(text[:200])).encode(), "text/html; charset=utf-8")
        return self.reply(404, b"not found")

    def stream(self, tag, kind, chunk, content_type):
        """A response that never ends: one chunk a second until the client goes."""
        key = self.port
        self.close_connection = True
        self.send_response(200)
        self.send_header("Content-Type", content_type)
        self.send_header("Cache-Control", "no-store")
        self.send_header("Connection", "close")
        self.end_headers()
        STATS.opened(tag, kind, key)
        log(f"[{tag}] {kind} :{key} opened")
        started, n, why = time.monotonic(), 0, "server ended it"
        try:
            while time.monotonic() - started < HOLD_SECONDS:
                if client_gone(self.connection):
                    why = "closed by the client"
                    break
                self.wfile.write(chunk(n))
                self.wfile.flush()
                n += 1
                time.sleep(1)
        except OSError as error:
            why = f"write failed ({error.__class__.__name__})"
        finally:
            STATS.closed(tag, kind, key)
            log(f"[{tag}] {kind} :{key} {why} after {n} chunk(s)")

    def download(self, tag):
        key = self.port
        self.close_connection = True
        self.send_response(200)
        self.send_header("Content-Type", "application/octet-stream")
        self.send_header("Content-Disposition", 'attachment; filename="freeze-spike.bin"')
        self.send_header("Content-Length", str(DOWNLOAD_BYTES))
        self.send_header("Cache-Control", "no-store")
        self.end_headers()
        STATS.opened(tag, "download", key)
        log(f"[{tag}] download :{key} started")
        sent, why = 0, "finished"
        try:
            while sent < DOWNLOAD_BYTES:
                if client_gone(self.connection):
                    why = "closed by the client"
                    break
                self.wfile.write(b"\0" * 1024)
                self.wfile.flush()
                sent += 1024
                time.sleep(1)
        except OSError as error:
            why = f"write failed ({error.__class__.__name__})"
        finally:
            STATS.closed(tag, "download", key)
            log(f"[{tag}] download :{key} {why} at {sent // 1024} KiB")

    def hold(self, tag, src):
        """A keepalive fetch: read, then answer only after HOLD_SECONDS or never."""
        key = self.port
        kind = src
        STATS.opened(tag, kind, key)
        log(f"[{tag}] {kind} :{key} received, holding the answer")
        started, why = time.monotonic(), None
        try:
            while time.monotonic() - started < HOLD_SECONDS:
                if client_gone(self.connection):
                    why = "closed by the client"
                    break
                time.sleep(0.5)
            if why is None:
                why = "answered"
                self.reply(200, b"ok")
        except OSError as error:
            why = f"failed ({error.__class__.__name__})"
        finally:
            STATS.closed(tag, kind, key)
            log(f"[{tag}] {kind} :{key} {why} after {int(time.monotonic() - started)} s")
            self.close_connection = True

    def slow_redirect(self, tag):
        """S1 redirects: hold the request 2 s, then redirect it to /ping?src=redirected.

        A restriction installed meanwhile must cancel the request ("closed by
        the client"); if it did not, the redirect must not be followed (no
        `redirected` count afterwards)."""
        key = self.port
        STATS.opened(tag, "redirect", key)
        started, why = time.monotonic(), None
        try:
            while time.monotonic() - started < 2:
                if client_gone(self.connection):
                    why = "closed by the client before the redirect"
                    break
                time.sleep(0.1)
            if why is None:
                self.send_response(302)
                self.send_header("Location", f"/ping?src=redirected&tag={tag}")
                self.send_header("Content-Length", "0")
                self.send_header("Cache-Control", "no-store")
                self.end_headers()
                why = "redirect sent"
        except OSError as error:
            why = f"failed ({error.__class__.__name__})"
        finally:
            STATS.closed(tag, "redirect", key)
            if why != "redirect sent":
                log(f"[{tag}] redirect :{key} {why}")

    def websocket(self, tag):
        key_header = self.headers.get("Sec-WebSocket-Key")
        if not key_header:
            return self.reply(400, b"not a websocket request")
        accept = base64.b64encode(hashlib.sha1((key_header + WS_GUID).encode()).digest()).decode()
        self.send_response(101, "Switching Protocols")
        self.send_header("Upgrade", "websocket")
        self.send_header("Connection", "Upgrade")
        self.send_header("Sec-WebSocket-Accept", accept)
        self.end_headers()
        self.wfile.flush()
        self.close_connection = True
        sock, key, buf, n, why = self.connection, self.port, b"", 0, "server ended it"
        STATS.opened(tag, "ws", key)
        log(f"[{tag}] ws :{key} opened")
        started = time.monotonic()
        try:
            while time.monotonic() - started < HOLD_SECONDS:
                sock.sendall(ws_frame(f"server {n}"))
                n += 1
                deadline = time.monotonic() + 1
                while (left := deadline - time.monotonic()) > 0:
                    readable, _, _ = select.select([sock], [], [], left)
                    if not readable:
                        break
                    data = sock.recv(4096)
                    if not data:
                        why = "closed by the client (no close frame)"
                        return
                    buf += data
                    while (frame := ws_parse(buf)) is not None:
                        opcode, _, consumed = frame
                        buf = buf[consumed:]
                        if opcode == 8:
                            why = "closed by the client (close frame)"
                            sock.sendall(bytes([0x88, 0]))
                            return
                        if opcode == 1:
                            STATS.hit(tag, "ws-in")
        except OSError as error:
            why = f"failed ({error.__class__.__name__})"
        finally:
            STATS.closed(tag, "ws", key)
            log(f"[{tag}] ws :{key} {why} after {n} frame(s) sent")

    def send_push(self, tag):
        subscription = ENDPOINTS.get(tag)
        if not subscription:
            return self.reply(404, f"no push endpoint for tag '{tag}' yet; open or reload the page\n".encode())
        payload = json.dumps({"tag": tag, "sent": stamp()}).encode()
        body = encrypt_push(subscription, payload)
        headers = {"TTL": "60"}
        if body is None:
            body = b""
            log(f"[{tag}] sending an EMPTY push (no keys or no python cryptography); Sunup drops those")
        else:
            headers.update({"Content-Encoding": "aes128gcm", "Content-Type": "application/octet-stream"})
        request = urllib.request.Request(subscription["endpoint"], data=body, method="POST", headers=headers)
        try:
            with urllib.request.urlopen(request, timeout=20) as response:
                status, detail = response.status, ""
        except urllib.error.HTTPError as error:
            status, detail = error.code, error.read()[:300].decode(errors="replace")
        except OSError as error:
            status, detail = 0, str(error)
        log(f"[{tag}] push sent, push service answered {status} {detail}".rstrip())
        return self.reply(200, f"push service answered {status} {detail}\n".encode())


def preconnect_listener(port):
    """Logs every TCP connection on `port`: speculative connections from preconnect hints."""
    server = socket.create_server(("127.0.0.1", port), reuse_port=False)
    server.listen()

    def serve(conn, peer):
        with conn:
            conn.settimeout(2)
            try:
                data = conn.recv(200)
            except OSError:
                data = b""
            what = f"then sent {data[:40]!r}" if data else "sent nothing (speculative)"
            log(f"[tcp:{port}] connection from :{peer[1]}, {what}")

    while True:
        conn, peer = server.accept()
        threading.Thread(target=serve, args=(conn, peer), daemon=True).start()


def ticker():
    while True:
        time.sleep(1)
        STATS.tick()


SCRIPTS = {
    "/sw.js": r"""
const tag = new URL(location).searchParams.get('tag') || 'frozen';
const q = src => `src=${src}&tag=${encodeURIComponent(tag)}`;
self.addEventListener('install', () => self.skipWaiting());
self.addEventListener('activate', e => e.waitUntil(self.clients.claim()));
self.addEventListener('message', e => e.waitUntil(
  fetch(`/ping?${q('sw-message')}`).then(
    () => e.source && e.source.postMessage('answered ' + new Date().toLocaleTimeString()),
    err => e.source && e.source.postMessage('fetch refused: ' + err))));
// The notification is the proof the worker ran even if its fetch is refused.
self.addEventListener('push', e => e.waitUntil(Promise.allSettled([
  fetch(`/ping?${q('sw-push')}`),
  self.registration.showNotification('Freeze spike push (' + tag + ')',
    { body: 'Service worker ran at ' + new Date().toLocaleTimeString() + (e.data ? ' ' + e.data.text() : ''), tag: 'spike-' + tag,
    // E12 device test: a button, to try the action path next to the plain tap.
    actions: tag.startsWith('open') ? [{ action: 'reply', title: 'Reply' }] : [] }),
])));
self.addEventListener('notificationclick', e => {
  // E12 device test N4: a tag with "keep" leaves the notification alone, so what
  // the app does to it on a button or a body tap can be told from the site's own
  // close(), which cancels it at once.
  if (!tag.includes('keep')) e.notification.close();
  // A button reports itself and opens nothing; a tap on the body is the plain click.
  if (e.action) {
    e.waitUntil(fetch(`/ping?${q('sw-action-' + e.action)}`));
    return;
  }
  e.waitUntil(Promise.all([
    fetch(`/ping?${q('sw-notificationclick')}`),
    // E12 device test: only a tag starting "open" also opens a window, so the
    // S1 tags keep their old behaviour. A refusal is reported, not swallowed.
    tag.startsWith('open')
      ? self.clients.openWindow(`/opened?${q('opened')}`).catch(() => fetch(`/ping?${q('openwindow-refused')}`))
      : null,
  ]));
});
self.addEventListener('pushsubscriptionchange', e => e.waitUntil(fetch(`/ping?${q('sw-pushsubscriptionchange')}`)));
""",
    "/shared.js": r"""
const tag = new URL(location).searchParams.get('tag') || 'frozen';
const ports = [];
onconnect = e => { ports.push(e.ports[0]); };
let n = 0;
setInterval(() => {
  n++;
  fetch(`/ping?src=shared&tag=${encodeURIComponent(tag)}`).then(
    () => ports.forEach(p => p.postMessage('ping ' + n + ' ok')),
    err => ports.forEach(p => p.postMessage('ping ' + n + ' refused: ' + err)));
}, 1000);
""",
    "/worker.js": r"""
const tag = new URL(location).searchParams.get('tag') || 'frozen';
fetch(`/keepalive?src=keepalive-worker&tag=${encodeURIComponent(tag)}`,
  { method: 'POST', body: 'w', keepalive: true }).catch(() => {});
postMessage('sent');
""",
}

OPENED_PAGE = """<!doctype html>
<html><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>Opened by a notification</title></head>
<body style="font-family:sans-serif;font-size:1.3em;padding:1em">
<h1>Opened by a notification click</h1>
<p>Tag: <b>{tag}</b></p>
<p>Storage markers this page carried: <b>{markers}</b></p>
<p>In the right container this shows <b>spike-{tag} (this run)</b>. In the default storage, or another container, it shows <b>none</b>, another tag's marker, or a stale one from an earlier run.</p>
</body></html>
"""

FORM_PAGE = """<!doctype html>
<html><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>S12 form</title></head><body style="font:16px system-ui,sans-serif;margin:16px">
<h1 style="font-size:18px">S12: POST form (TAG)</h1>
<form method="post" action="/posted?tag=TAG">
 <p><label>Message <input name="msg" value=""></label></p>
 <p><button>Send as POST</button></p>
</form></body></html>
"""

POSTED_PAGE = """<!doctype html>
<html><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>S12 result</title></head><body style="font:16px system-ui,sans-serif;margin:16px">
<h1 style="font-size:18px">Result page</h1>
<p>Served at <b>{when}</b> for a <b>{how}</b>.</p>
<p>Body: <code>{body}</code></p>
</body></html>
"""

PAGE = r"""<!doctype html>
<html><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>Freeze spike</title>
<style>
 body{font:14px system-ui,sans-serif;margin:12px;background:#fff;color:#111}
 @media (prefers-color-scheme:dark){body{background:#111;color:#eee}}
 table{border-collapse:collapse;width:100%} td{padding:3px 6px;border-bottom:1px solid #8884;vertical-align:top}
 td:first-child{font-weight:600;white-space:nowrap} td:last-child{font-variant-numeric:tabular-nums;opacity:.7;white-space:nowrap}
 button,a.btn{font:inherit;margin:4px 4px 4px 0;padding:6px 10px}
 h1{font-size:18px;margin:0 0 8px}
</style></head><body>
<h1>Freeze spike: <span id="tag"></span></h1>
<div>
 <button id="subscribe">Subscribe to push</button>
 <a class="btn" href="/download" id="download" download>Start long download</a>
 <button id="webrtc">Start WebRTC (TURN)</button>
 <button id="open">window.open</button>
</div>
<table id="rows"></table>
<script>
const tag = new URLSearchParams(location.search).get('tag') || 'frozen';
document.getElementById('tag').textContent = tag;
document.getElementById('download').href = '/download?tag=' + encodeURIComponent(tag);
const q = src => `src=${src}&tag=${encodeURIComponent(tag)}`;
const table = document.getElementById('rows');
const rows = {};
function status(name, text) {
  let row = rows[name];
  if (!row) { row = rows[name] = table.insertRow(); row.insertCell(); row.insertCell(); row.insertCell(); row.cells[0].textContent = name; }
  row.cells[1].textContent = text;
  row.cells[2].textContent = new Date().toLocaleTimeString();
}

// Plain fetch, every second.
setInterval(() => fetch(`/ping?${q('page')}`, { cache: 'no-store' })
  .then(r => status('fetch', 'ok ' + r.status), e => status('fetch', 'refused: ' + e)), 1000);

// EventSource (reconnects by itself).
const es = new EventSource(`/events?${q('sse')}`);
es.onmessage = e => status('eventsource', 'got ' + e.data);
es.onerror = () => status('eventsource', 'error, readyState ' + es.readyState);

// WebSocket, a frame each way every second; reconnects after 3 s.
function ws() {
  let s;
  try { s = new WebSocket(`ws://${location.host}/ws?${q('ws')}`); }
  catch (e) { status('websocket', 'threw ' + e); return setTimeout(ws, 3000); }
  let timer;
  s.onopen = () => { status('websocket', 'open'); let n = 0; timer = setInterval(() => s.send('page ' + n++), 1000); };
  s.onmessage = e => status('websocket', 'got ' + e.data);
  s.onclose = e => { clearInterval(timer); status('websocket', 'closed ' + e.code); setTimeout(ws, 3000); };
}
ws();

// A response that drips a byte a second.
async function slow() {
  try {
    const r = await fetch(`/slow?${q('slow')}`, { cache: 'no-store' });
    const reader = r.body.getReader();
    let n = 0;
    for (;;) { const { done, value } = await reader.read(); if (done) break; n += value.length; status('slow response', n + ' bytes'); }
    status('slow response', 'ended');
  } catch (e) { status('slow response', 'failed: ' + e); }
  setTimeout(slow, 3000);
}
slow();

// Keepalive fetches the server never answers: one from the page, one from a worker terminated right after.
fetch(`/keepalive?${q('keepalive-page')}`, { method: 'POST', body: 'k', keepalive: true })
  .then(r => status('keepalive (page)', 'answered ' + r.status), e => status('keepalive (page)', 'failed: ' + e));
status('keepalive (page)', 'sent, the server holds it');
try {
  const w = new Worker(`/worker.js?${q('keepalive-worker')}`);
  w.onmessage = () => setTimeout(() => { w.terminate(); status('keepalive (worker)', 'sent, worker terminated'); }, 1000);
  w.onerror = e => status('keepalive (worker)', 'worker error: ' + e.message);
} catch (e) { status('keepalive (worker)', 'threw ' + e); }

// Shared worker, fetch every second.
try {
  const sw = new SharedWorker(`/shared.js?${q('shared')}`);
  sw.port.onmessage = e => status('shared worker', e.data);
  sw.port.start();
} catch (e) { status('shared worker', 'threw ' + e); }

// Service worker: a message every 5 s makes it fetch; push shows a notification.
async function serviceWorker() {
  if (!('serviceWorker' in navigator)) return status('service worker', 'not supported');
  try {
    const reg = await navigator.serviceWorker.register(`/sw.js?${q('sw')}`, { scope: '/' });
    await navigator.serviceWorker.ready;
    status('service worker', 'registered');
    navigator.serviceWorker.onmessage = e => status('service worker', e.data);
    setInterval(() => { const c = navigator.serviceWorker.controller || reg.active; if (c) c.postMessage('ping'); }, 5000);
    const sub = await reg.pushManager.getSubscription();
    status('push', sub ? 'subscribed: ' + sub.endpoint.slice(0, 48) + '…' : 'not subscribed: tap Subscribe');
    if (sub) postEndpoint(sub);
  } catch (e) { status('service worker', 'failed: ' + e); }
}
function postEndpoint(sub) { fetch(`/endpoint?${q('push')}`, { method: 'POST', body: JSON.stringify(sub) }); }
document.getElementById('subscribe').onclick = async () => {
  try {
    await Notification.requestPermission();
    const reg = await navigator.serviceWorker.ready;
    const sub = await reg.pushManager.subscribe({ userVisibleOnly: true });
    // GeckoView resolves with null when the app could not subscribe (no delivery app chosen, timeout).
    if (!sub) return status('push', 'no subscription: is a Notification Delivery App chosen in WebLibre?');
    status('push', 'subscribed: ' + sub.endpoint.slice(0, 48) + '…');
    postEndpoint(sub);
  } catch (e) { status('push', 'failed: ' + e); }
};
serviceWorker();

// Beacons when the page is hidden or unloaded.
addEventListener('pagehide', () => navigator.sendBeacon(`/beacon?${q('pagehide')}`, 'b'));
document.addEventListener('visibilitychange', () => {
  if (document.visibilityState === 'hidden') navigator.sendBeacon(`/beacon?${q('hidden')}`, 'b');
  status('visibility', document.visibilityState);
});
status('visibility', document.visibilityState);

// A request the server answers after 2 s with a redirect (to /ping?src=redirected).
setInterval(() => fetch(`/redirect?${q('redirect')}`, { cache: 'no-store' })
  .then(r => status('redirect', 'followed, ' + r.status), e => status('redirect', 'failed: ' + e)), 3000);

// Preconnect hints to the raw TCP listener on 8081 (it logs the accepts).
setInterval(() => {
  const l = document.createElement('link');
  l.rel = 'preconnect'; l.href = 'http://127.0.0.1:8081/';
  document.head.appendChild(l);
  setTimeout(() => l.remove(), 2000);
  status('preconnect', 'hinted');
}, 5000);

// WebRTC data channel between two local peers, relay only, through TURN over TCP.
document.getElementById('webrtc').onclick = async () => {
  if (!window.RTCPeerConnection) return status('webrtc', 'RTCPeerConnection not available');
  const cfg = { iceServers: [{ urls: '@TURN_URL@', username: 'spike', credential: 'spike' }], iceTransportPolicy: 'relay' };
  const a = new RTCPeerConnection(cfg), b = new RTCPeerConnection(cfg);
  a.onicecandidate = e => e.candidate && b.addIceCandidate(e.candidate);
  b.onicecandidate = e => e.candidate && a.addIceCandidate(e.candidate);
  a.onconnectionstatechange = () => status('webrtc state', a.connectionState);
  const ch = a.createDataChannel('spike');
  b.ondatachannel = e => { e.channel.onmessage = m => status('webrtc', 'got ' + m.data); };
  let n = 0;
  ch.onopen = () => setInterval(() => { if (ch.readyState === 'open') ch.send('tick ' + n++); }, 1000);
  ch.onclose = () => status('webrtc', 'channel closed');
  const offer = await a.createOffer(); await a.setLocalDescription(offer); await b.setRemoteDescription(offer);
  const answer = await b.createAnswer(); await b.setLocalDescription(answer); await a.setRemoteDescription(answer);
  status('webrtc', 'connecting through TURN');
};

document.getElementById('open').onclick = () => {
  const w = window.open(`/?tag=${encodeURIComponent(tag)}-popup`);
  status('window.open', w ? 'opened' : 'returned null');
};
</script></body></html>
"""


def lan_address():
    """The host address on the default route (no packet is sent)."""
    with socket.socket(socket.AF_INET, socket.SOCK_DGRAM) as s:
        try:
            s.connect(("192.0.2.1", 9))
            return s.getsockname()[0]
        except OSError:
            return "127.0.0.1"


def turnserver_command(host, port):
    # coturn 4.19 has no --no-dtls: DTLS is off unless --dtls.
    return (f"turnserver -n --listening-ip={host} --listening-port={port} --relay-ip={host} "
            f"--allowed-peer-ip={host} --lt-cred-mech --user=spike:spike --realm=spike "
            "--no-tls --cli-password=spike --log-file=stdout --verbose")


def main():
    global TURN_URL
    parser = argparse.ArgumentParser(
        description="Test server for the container freeze spikes S1 and S11.",
        epilog=(
            "WebRTC needs a TURN server (coturn, user spike/spike) on the host's LAN address, reached "
            "by the device over the network: Gecko skips TURN servers on loopback addresses "
            "(media.peerconnection.ice.loopback), so an adb reverse port does not work. The server "
            "prints the turnserver command for --turn-host. The host firewall must let the device "
            "reach the TURN port, for example: sudo firewall-cmd --zone=public --add-port=3478/tcp"
        ),
    )
    parser.add_argument("--port", type=int, default=8080)
    parser.add_argument("--preconnect-port", type=int, default=8081)
    parser.add_argument("--turn-host", default=lan_address(),
                        help="TURN server address the page uses (default: this host's LAN address)")
    parser.add_argument("--turn-port", type=int, default=3478)
    args = parser.parse_args()
    TURN_URL = f"turn:{args.turn_host}:{args.turn_port}?transport=tcp"

    server = ThreadingHTTPServer(("127.0.0.1", args.port), Handler)
    server.daemon_threads = True
    threading.Thread(target=ticker, daemon=True).start()
    threading.Thread(target=preconnect_listener, args=(args.preconnect_port,), daemon=True).start()
    log(f"Freeze spike server on http://localhost:{args.port}/ (preconnect target :{args.preconnect_port})")
    log(f"adb reverse tcp:{args.port} tcp:{args.port} && adb reverse tcp:{args.preconnect_port} tcp:{args.preconnect_port}")
    log(f"WebRTC uses {TURN_URL}; TURN server: {turnserver_command(args.turn_host, args.turn_port)}")
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        sys.exit(0)


if __name__ == "__main__":
    main()
