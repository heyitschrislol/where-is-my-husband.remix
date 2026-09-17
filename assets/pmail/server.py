    #!/usr/bin/env python3
from http.server import BaseHTTPRequestHandler, HTTPServer
from urllib.parse import parse_qs, urlparse
import os, html, secrets, sys, threading, time

HOST = "127.0.0.1"
PORT = int(sys.argv[1]) if len(sys.argv) > 1 else 8080
PARENT_PID = int(sys.argv[2]) if len(sys.argv) > 2 else 0

WEB_DIR = os.path.join(os.path.dirname(__file__), "web")

# Required login
REQUIRED_EMAIL = "husbandssecret@pmail.com"
REQUIRED_PASSWORD = "kithy"  # <-- set this

# Cosmetic
BRAND = "Pmail"
ACCOUNT_NAME = "husbandssecret"
SERVICE_DOMAIN = "pmail.com"

# Fake inbox
MESSAGES = [
    # {
    #     "id": "1",
    #     "from_name": "Pmail Team",
    #     "from_email": f"no-reply@{SERVICE_DOMAIN}",
    #     "subject": "Welcome to Pmail! ",
    #     "snippet": "Please verify access…",
    #     "date": "Feb 14",
    #     "body_html": """
    #       <p>Hi <b><i>husbandssecret</b></i>,</p>
    #       <p>Congratulations! You now have access over 2gb of fast and free email storage! </p>
    #       <p><b>Your next clue:</b></p>
    #       <div style="margin-top:10px;background:#f1f3f4;border:1px solid #e2e5ea;padding:12px 14px;border-radius:12px;font-family:ui-monospace,SFMono-Regular,Menlo,Monaco,Consolas,'Liberation Mono',monospace;">
    #         Next clue: check the kitchen drawer under the forks.
    #       </div>
    #       <p style="margin-top:14px;">— Pmail Security</p>
    #     """
    # },
    {
        "id": "1",
        "from_name": "Pmail Team",
        "from_email": f"no-reply@{SERVICE_DOMAIN}",
        "subject": "Welcome to Pmail! ",
        "snippet": "Please verify access…",
        "date": "July 14", 
        "body_html": """
        <p>Hi there,</p>

        <p>Welcome to <b>Pmail</b> — your new inbox is ready.</p>

        <p style='margin:16px 0;'>
          To finish setting up your account, please confirm your email address:
        </p>

        <p style='margin:18px 0;'>
          <a href='#'
             style='
               display:inline-block;
               background:#1a73e8;
               color:#ffffff;
               text-decoration:none;
               padding:10px 16px;
               border-radius:8px;
               font-weight:600;
               font-size:14px;
             '>
            Confirm email address
          </a>
        </p>

        <p style='margin:16px 0; color:#5f6368;'>
          If the button doesn’t work, copy and paste this link into your browser:
          <br/>
          <span style='font-family:ui-monospace,SFMono-Regular,Menlo,Monaco,Consolas,'Liberation Mono',monospace;'>
            https://pmail.com/verify?token=9f3c-2a11-8c0d
          </span>
        </p>

        <hr style='border:none;border-top:1px solid #e0e3eb;margin:18px 0;'/>

        <p style='margin:0 0 10px;'><b>Your verification code</b></p>

        <div style='
          background:#f1f3f4;
          border:1px solid #e2e5ea;
          border-radius:12px;
          padding:12px 14px;
          font-family:ui-monospace,SFMono-Regular,Menlo,Monaco,Consolas,'Liberation Mono',monospace;
          font-size:16px;
          letter-spacing:2px;
          display:inline-block;
        '>
          482&nbsp;913
        </div>

        <p style='margin-top:12px; color:#5f6368; font-size:13px;'>
          This code expires in 10 minutes.
        </p>

        <p style='margin:18px 0 0;'>
          If you didn’t create a Pmail account, you can ignore this email.
        </p>

        <p style='margin-top:18px;'>
          — The Pmail Team
        </p>

        <p style='margin-top:18px; color:#5f6368; font-size:12px; line-height:1.4;'>
          This message was sent to you because a Pmail account was created using this email address.
          <br/>
          Pmail, Inc. • 123 Inbox Lane • Internet City
        </p>
        """
    },
    {
        "id": "2",
        "from_name": "Calendar",
        "from_email": f"calendar@{SERVICE_DOMAIN}",
        "subject": "Reminder: PREPARE SURPRISE IN BEDROOM CLOSET",
        "snippet": "BEFORE B GETS HOME FROM WORK",
        "date": "Aug 23",
        "body_html": "<p>Reminder: Don’t forget to prepare the surprise <b>in the bedroom closet</b> </p>"
    },
    {
        "id": "3",
        "from_name": "Notes",
        "from_email": f"notes@{SERVICE_DOMAIN}",
        "subject": "Draft saved",
        "snippet": "Draft: “Promises...”…",
        "date": "Aug 31",
        "body_html": """
            <p><b>Draft:</b></p>
            <p> <s>You, my wife, are -- like -- the best wife. I have friends who also have a wife, but they aren't near as good of a wife as you.</s> (<i>--NOTE: delete practice draft and never let wife see this crap</i>)</p>
        """
    },
]

# sid -> {"read": set(ids)}
SESSIONS = {}

def esc(s: str) -> str:
    return html.escape(s, quote=True)

def load_template(name: str) -> str:
    path = os.path.join(WEB_DIR, name)
    with open(path, "r", encoding="utf-8") as f:
        return f.read()

def render(tpl: str, **vars) -> str:
    # Very simple placeholder replacement: {{NAME}}
    for k, v in vars.items():
        tpl = tpl.replace("{{" + k + "}}", v)
    return tpl

def get_cookie(headers, name):
    c = headers.get("Cookie", "")
    parts = [p.strip() for p in c.split(";") if "=" in p]
    for p in parts:
        k, v = p.split("=", 1)
        if k.strip() == name:
            return v.strip()
    return None

class Handler(BaseHTTPRequestHandler):
    def send_html(self, code, html_text, set_cookie=None, location=None):
        data = html_text.encode("utf-8")
        self.send_response(code)
        if location:
            self.send_header("Location", location)
        self.send_header("Content-Type", "text/html; charset=utf-8")
        self.send_header("Content-Length", str(len(data)))
        if set_cookie:
            self.send_header("Set-Cookie", set_cookie)
        self.end_headers()
        self.wfile.write(data)

    def session(self):
        sid = get_cookie(self.headers, "sid")
        if not sid:
            return None, None
        return sid, SESSIONS.get(sid)

    def authed(self):
        _, s = self.session()
        return s is not None

    def unread_count(self, s):
        read = s["read"]
        return sum(1 for m in MESSAGES if m["id"] not in read)

    def do_GET(self):
        parsed = urlparse(self.path)
        path = parsed.path
        qs = parse_qs(parsed.query)

        if path == "/":
            err = "bad" in qs
            error_block = "<div class='error'>Wrong email or password.</div>" if err else ""
            tpl = load_template("login.html")
            page = render(
                tpl,
                TITLE=f"{BRAND} - Sign in",
                BRAND=esc(BRAND),
                EMAIL=esc(REQUIRED_EMAIL),
                ERROR_BLOCK=error_block,
            )
            self.send_html(200, page)
            return

        if path == "/mail/u/0/inbox":
            sid, s = self.session()
            if not s:
                self.send_html(302, "", location="/")
                return

            unread = self.unread_count(s)
            rows_html = []
            for m in MESSAGES:
                is_unread = (m["id"] not in s["read"])
                rows_html.append(
                    f"""
                    <div class="row {'unread' if is_unread else ''}">
                      <a href="/mail/u/0/message/{esc(m['id'])}">
                        <div class="dot" aria-hidden="true"></div>
                        <div class="from">{esc(m['from_name'])}</div>
                        <div class="subj">{esc(m['subject'])}
                          <span class="snippet"> — {esc(m['snippet'])}</span>
                        </div>
                        <div class="date">{esc(m['date'])}</div>
                      </a>
                    </div>
                    """
                )

            tpl = load_template("inbox.html")
            page = render(
                tpl,
                TITLE=f"{BRAND} - Inbox",
                BRAND=esc(BRAND),
                ACCOUNT_NAME=esc(ACCOUNT_NAME),
                EMAIL=esc(REQUIRED_EMAIL),
                UNREAD_COUNT=str(unread),
                UNREAD_BADGE=(str(unread) if unread > 0 else ""),
                ROWS="".join(rows_html),
            )
            self.send_html(200, page)
            return

        if path.startswith("/mail/u/0/message/"):
            sid, s = self.session()
            if not s:
                self.send_html(302, "", location="/")
                return

            msg_id = path.rsplit("/", 1)[-1]
            m = next((x for x in MESSAGES if x["id"] == msg_id), None)
            if not m:
                self.send_html(404, "Not found")
                return

            s["read"].add(msg_id)

            tpl = load_template("message.html")
            page = render(
                tpl,
                TITLE=f"{BRAND} - {m['subject']}",
                BRAND=esc(BRAND),
                ACCOUNT_NAME=esc(ACCOUNT_NAME),
                EMAIL=esc(REQUIRED_EMAIL),
                SUBJECT=esc(m["subject"]),
                FROM_NAME=esc(m["from_name"]),
                FROM_EMAIL=esc(m["from_email"]),
                DATE=esc(m["date"]),
                BODY_HTML=m["body_html"],  # intentionally not escaped (you control it)
            )
            self.send_html(200, page)
            return

        if path == "/logout":
            sid = get_cookie(self.headers, "sid")
            if sid in SESSIONS:
                del SESSIONS[sid]
            self.send_html(302, "", set_cookie="sid=; Path=/; Max-Age=0; SameSite=Lax", location="/")
            return

        self.send_html(404, "Not found")

    def do_POST(self):
        path = urlparse(self.path).path
        length = int(self.headers.get("Content-Length", 0))
        raw = self.rfile.read(length).decode("utf-8", errors="replace")
        form = parse_qs(raw)

        if path == "/auth":
            email_in = (form.get("email", [""])[0] or "").strip()
            pw_in = (form.get("password", [""])[0] or "").strip()

            time.sleep(0.9)  # fake "signing in..."

            if email_in.lower() == REQUIRED_EMAIL.lower() and pw_in == REQUIRED_PASSWORD:
                sid = secrets.token_urlsafe(16)
                SESSIONS[sid] = {"read": set()}
                self.send_html(
                    302, "",
                    set_cookie=f"sid={sid}; Path=/; SameSite=Lax",
                    location="/mail/u/0/inbox"
                )
            else:
                time.sleep(0.4)
                self.send_html(302, "", location="/?bad=1")
            return

        self.send_html(404, "Not found")

def _parent_alive(pid):
    if pid <= 0:
        return True
    if os.name == "nt":
        import ctypes
        PROCESS_QUERY_LIMITED_INFORMATION = 0x1000
        STILL_ACTIVE = 259
        k = ctypes.windll.kernel32
        h = k.OpenProcess(PROCESS_QUERY_LIMITED_INFORMATION, False, pid)
        if not h:
            return False
        code = ctypes.c_ulong()
        ok = k.GetExitCodeProcess(h, ctypes.byref(code))
        k.CloseHandle(h)
        return bool(ok) and code.value == STILL_ACTIVE
    try:
        os.kill(pid, 0)       # signal 0 = existence check, sends nothing
    except OSError:
        return False
    return True


def _watchdog(pid):
    while True:
        time.sleep(1.0)
        if not _parent_alive(pid):
            os._exit(0)       # blunt on purpose: guarantees the socket dies with us

class ExclusiveHTTPServer(HTTPServer):
    allow_reuse_address = False

def main():
    threading.Thread(target=_watchdog, args=(PARENT_PID,), daemon=True).start()
    # httpd = HTTPServer((HOST, PORT), Handler)
    httpd = ExclusiveHTTPServer((HOST, PORT), Handler)
    print(f"Serving on http://{HOST}:{PORT}")
    httpd.serve_forever()
    # httpd = HTTPServer((HOST, PORT), Handler)
    # print(f"Serving on http://{HOST}:{PORT}")
    # httpd.serve_forever()

if __name__ == "__main__":
    main()
