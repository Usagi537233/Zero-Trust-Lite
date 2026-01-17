# Zero-Trust-Lite

A lightweight Zero Trust middleware providing **TOTP verification** + **trusted IP long session**, designed for self-hosted services, internal dashboards, and private tools.

Unlike normal TOTP implementations, this project uses a **remote TOTP provider binding model** with a **private TOTP protocol**. **Now, starting from version 0.1.7, it also supports COTP** ([COTP Protocol](https://github.com/Usagi537233/COTP-Protocol)) for enhanced security.

Let me know if you'd like any further adjustments!


> **TOTP is generated at:**  
> Users must create a token and visit:
> https://ipsafev2.537233.xyz/  
> using a user-owned `token`, shared by both the remote TOTP page and this middleware.
> https://ipsafev2.537233.xyz/yourpath/totp?token=YourToken

> **Basic TOTP generated at:**
> Users must create a token and visit:
> https://ipsafev2.537233.xyz/  
> using a user-owned `token`, get your Base32 Secret (Import TOTP Clients):.
> https://ipsafev2.537233.xyz/yourpath/basictotp?token=YourToken
> Then import your base32 secret to your 2fa apps.

> **COTP Calculator Web at(**In version 0.1.7 and above**):**
> [COTP Calculator](https://cotp.537233.xyz/)
> If you a IPM user,you can access the your path/cotp ,just like https://ipm.537233.xyz/yourpath/cotp .

## **Commitment to Availability:** If I ever decide to shut down the central auth service, I will release a **standalone offline tool**. This will allow you to generate real-time TOTP codes locally on your own machine, ensuring you can continue to use the system independently.

![image](./image.png?cache-bust=2)

![image1](./image1.png)

![image3](./image3.png?cache-bust=2)

![image2](./image2.png)

## To thank the users who support our professional site [https://ipm.537233.xyz](https://ipm.537233.xyz), this interactive TOTP page was made just for them — thank you all!

No implicit network trust. No backend modification. Works as a reverse proxy in front of any HTTP service.

---

DOC

[利用Zero-Trust-Lite保护你的探针面板，Komari为例](https://github.com/Usagi537233/Zero-Trust-Lite/blob/main/doc/%E5%88%A9%E7%94%A8Zero-Trust-Lite%E4%BF%9D%E6%8A%A4%E4%BD%A0%E7%9A%84%E6%8E%A2%E9%92%88%E9%9D%A2%E6%9D%BF%EF%BC%8CKomari%E4%B8%BA%E4%BE%8B.md)


---

## ✨ Core Design

### 🔐 COTP Calculator **In version 0.1.7 and above**

1. Click the **Copy COTP Challenge and Access Host** button in your ZTL web. This will copy both your challenge and host information.
2. Next, go to the [COTP Calculator Web](https://cotp.537233.xyz/) and submit the token from your ZTL settings.
3. The calculator will generate your COTP code. You can then copy this code and use it as your ZTL verification code.
4. If you a IPM user,you can access the your path/cotp ,just like https://ipm.537233.xyz/yourpath/cotp .

### 🔐 TOTP Binding

#### Remote Binding

1. Create a random `token` in https://ipsafev2.537233.xyz
2. Configure this middleware:  
   `token = "<your token>"`
3. Visit your personal TOTP page:  
   `https://ipsafev2.537233.xyz/yourpath/totp?token=yourtoken`
4. Enter the displayed TOTP to log in

Or you can run local authenticator apps.  

#### local authenticator apps.
using a user-owned token, get your Base32 Secret (Import TOTP Clients):

 `https://ipsafev2.537233.xyz/yourpath/basictotp?token=YourToken `
 
Then import your base32 secret to your 2fa apps.


### 🕗 Trusted IP Long Session
IP whitelist is **not bypass**.  
It only extends session lifetime after successful TOTP:

- Untrusted IP: short session
- Trusted IP: long session
- First access always requires TOTP or COTP(**In version 0.1.7 and above**)

> **IP reduces friction, not the security boundary.**

---

## ✨ Features

### 🎯 Zero Trust Lite Model
- **Private TOTP protocol as the core trust mechanism**
- **Now you can use with basic TOTP protocol**
- No implicit network trust
- Every access path is verified
- Short session validity by default

### 🔒 Path Knocking (Additional Access Sequence)
- Requires a predefined sequence of hidden paths to be visited in the correct order after successful TOTP verification
- Even with a valid TOTP, access is denied until the full knocking sequence is completed within the allowed time window
- Fully configurable sequence, time window, and post-success validity period
- Provides a second independent layer of defense against TOTP compromise or leakage
- Extremely difficult to detect or brute-force due to silent 204 responses and no logging
  
### 🔐 Strong Authentication

- **Standard TOTP Authentication** (Fully compatible with Google Authenticator, Microsoft Authenticator, Authy, and all third-party apps)
- Time drift tolerant (±30 seconds)
- Supports both standard 6-digit and legacy 8-digit codes (`totp_mode: "auto"` or `"8"`)
- **Multi-token support**  
  **In version 0.1.6 and above**, multiple TOTP secrets are supported  
  Use comma-separated format: `TOTPTOKEN1,TOTPTOKEN2,TOTPTOKEN3`  
  Any one of the valid tokens in the list can be used to authenticate successfully
- **Optional Email Secondary Confirmation** (Configurable globally or per path)
  - After successful TOTP verification, a one-time confirmation link is sent via email
  - User must click the link (valid for configurable TTL, default 15 minutes) to complete authentication
  - Link is strictly bound to original client IP, requested path, and short-lived
  - Provides strong defense against TOTP key compromise — even if the key is stolen, access requires email approval
  - Fully configurable SMTP support (Gmail, Outlook, etc., with STARTTLS)
  - Path-specific control via `PathTokens`: enable/disable independently and set custom recipient(s) per path
- **Advantages of Combined TOTP + Email Confirmation**
  - True complementary multi-factor: "something you have" (TOTP key in app) + "something you can access" (email inbox)
  - Mitigates risks from both TOTP key leakage and email compromise

### Path-Specific TOTP&COTP Authentication (PathTokens)

- Supports independent TOTP&COTP secrets for different URL paths or prefixes
- **Multi-token support**  
  **In version 0.1.6 and above**, multiple TOTP& COTP(**In version 0.1.7 and above**) tokens are supported  
  Use comma-separated format: `TOTPTOKEN1,TOTPTOKEN2,TOTPTOKEN3`  
  Any one of the valid tokens in the list can be used to authenticate successfully
- Paths ending with `/` → **prefix matching** (recommended for protecting entire directories, e.g., `/admin/`)
- Paths without trailing `/` → **exact matching**
- Form-based login sessions are bound to the authorized path scope
- Accessing other protected paths triggers re-authentication with the corresponding token
- Basic Auth remains stateless and validates per-request path-specific tokens
- Unmatched paths fall back to the global token (fully backward compatible)
- **Per-path email secondary confirmation** (via `require_email_confirm` and `confirm_email` fields in `PathTokens`)
  - Allows fine-grained policy: force email approval for sensitive paths (e.g., admin), disable for automated/API paths

## IP Ban Notification

Blocked IPs are added to the **ban list**. If SMTP is configured, a notification is sent when either the time since the last notification reaches `block-notify-interval` or the number of newly banned IPs reaches `block-notify-max-ips`.

```
-block-notify-interval 1m -block-notify-max-ips 100
````

> No SMTP configured = notifications are skipped.

---

## Circuit Breaker

The circuit breaker is triggered when the total number of banned IPs reaches `circuit-max-ip`. While active, all authentication attempts (TOTP, Basic Auth, etc.) are rejected, except for whitelisted IPs. Protection lasts for `circuit-time` and resets automatically.

```
-circuit-max-ip 150 -circuit-time 30m
```

**Purpose:** Protects the service during large-scale attacks. Recommended values: 100–300 for normal use, 80–150 for higher security.

### 🕗 Trusted Session Extension
For known IP addresses (e.g. office, VPN exit, home IP), the system can:
- Extend session lifetime
- Reduce manual authentication friction
- Still require initial TOTP verification

> **IP whitelist is NOT used as a trust bypass.**  
> It is only a **risk-based optimization** mechanism.

### 🧱 Middleware Architecture
- Works as a **reverse proxy**
- Fronts any local HTTP backend
- Zero modification to backend apps
- Stateless (optional state storage)

---

## 🏗️ Architecture

```
Client
   |
   |  (Access Attempt)
   v
Zero-Trust-Lite Middleware
   |
   |-- Check Session
   |      |-- Valid? → Proxy to backend
   |
   |-- Check IP Trusted
   |      |-- Yes → Issue extended session
   |
   |-- Challenge
          |-- Render TOTP page
          |-- Verify TOTP
          |-- Issue session cookie
          |-- Redirect to backend
   |
Backend Service (any HTTP app)
```

---

## 🔒 Security Model

### Trust Assumptions
- Backend should **not** be exposed directly
- Front layer is the **only entry point**
- No IP trust without TOTP or COTP(**In version 0.1.7 and above**) validation
- Trusted IPs only affect session duration

### Threat Considerations
Defends against:
- Credential guessing
- Unauthorized local access
- Session replay (time-bound)
- Direct access bypass attempts
- Device posture check Lite

Not a full Zero Trust replacement for:
- MFA device binding
- Continuous session scoring
- Internal lateral movement detection
- Path-level key isolation prevents compromise of one path from affecting others
  
This is “Lite” by design.

---

## 🧭 When Should You Use This?

This middleware is ideal for:

- personal projects
- private dashboards
- devops panels
- CI/CD web consoles
- database dashboards
- tools running on VPS
- limited user access

Not recommended for:
- enterprise SSO replacement
- public internet login systems
- anonymous multi-user platforms

---

## ⚙️ Configuration

~~~
Usage:
 Single: ./zero-trust-lite -L :8080 -backend http://backend -token SECRET
         -circuit-max-ip 50 -circuit-time 30m
 Multi : ./zero-trust-lite -c config.json

Detailed Flags:
  -L string
        Listen address
  -V    Show version and exit
  -adminpath string
        Admin path (random if empty)
  -backend string
        Backend URL
  -block string
        Block duration (default "5m")
  -block-notify-interval string
        Min interval between block notification emails (default "5m")
  -block-notify-max-ips int
        Max blocked IPs in buffer to trigger immediate notification (default 10)
  -c string
        Multi-instance config file
  -challenge-ratelimit string
        Rate limit for generating COTP challenges, format: requests/time window, e.g., 5/30s, 10/1m (default "5/30s")
  -circuit-max-ip int
        Max blocked IPs to trigger global circuit break (0=disabled)
  -circuit-time string
        Circuit break duration after trigger
  -config string
        Multi-instance config file
  -confirm-email string
        Recipient email addresses for confirmation
  -confirm-ttl string
        Confirmation link validity duration (default "15m")
  -cotp-challenge-ttl duration
        COTP challenge valid time (default 5m0s)
  -debug
        Enable debug logging
  -email-confirm
        Require email confirmation after successful TOTP verification
  -failedtime string
        Rate limit: 5/1m
  -interval int
        Update interval (default 60)
  -key string
        32-byte hex key
  -knock_opentime string
        Duration knock is valid after success in seconds
  -knock_time_window string
        Time window to complete all knocks in seconds
  -knockpath string
        Comma-separated knocking sequence paths (e.g. /a,/b,/c)
  -listen string
        Listen address
  -nmsession string
        Normal session duration (also for requests) (default "30s")
  -pathtoken value
        Path-specific config, format: /path=SECRET[:require_email_confirm=true|false][:confirm_email=admin@example.com] (can be repeated)
  -smtp-from string
        Sender email address
  -smtp-host string
        SMTP server hostname
  -smtp-pass string
        SMTP password
  -smtp-port int
        SMTP server port (default 587)
  -smtp-tls
        Use STARTTLS for SMTP connection (default true)
  -smtp-user string
        SMTP username
  -token string
        TOTPTOKEN (separate multiple with commas) e.g. TOTPTOKEN1,TOTPTOKEN2,TOTPTOKEN3
  -totp-mode string
        TOTP mode: 'auto' (standard TOTP 6-digit, 8-digit & COTP), '8' (8-digit & COTP), 'cotp' (COTP only) (default "8")
  -v    Show version and exit
  -version
        Show version and exit
  -whitelistlocal string
        Local whitelist file
  -whitelisturl string
        Whitelist URL
  -wlsession string
        Whitelist session duration (default "5m")
  -wlurl string
        Whitelist URL
~~~

Simple run examle
~~~
./zero-trust-lite -backend http://yourbackend -token YourToken -listen 127.0.0.1:8082 -wlurl https://ipsafe2.537233.xyz/yourpath/iplist?token=YourToken
~~~

Example Nginx Configuration
~~~
    location / {
        proxy_pass http://127.0.0.1:8082;
        ....
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        ....
    } 
~~~

This setup ensures:

HTTPS terminated at Nginx

Zero-Trust-Lite receives the true client IP for session & whitelist logic

Preserves X-Forwarded-For chain for multi-proxy environments.

### Using HTTP Authorization token:TOTP

Zero-Trust-Lite supports one-line non-interactive login using HTTP headers:

Example:

~~~
curl https://token:totpcode@your-domain.com
~~~
