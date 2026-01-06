# Zero-Trust-Lite

A lightweight Zero Trust middleware providing **TOTP verification** + **trusted IP long session**, designed for self-hosted services, internal dashboards, and private tools.

Unlike normal TOTP implementations, this project uses a **remote TOTP provider binding model** with a **private TOTP protocol** **Now you can use with basic TOTP protocol**.  

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

### 🔐 Remote TOTP Binding
Users do not run local authenticator apps.  
Instead:

1. Create a random `token`
2. Configure this middleware:  
   `token = "<your token>"`
3. Visit your personal TOTP page:  
   `https://ipsafev2.537233.xyz/yourpath/totp?token=yourtoken`
4. Enter the displayed TOTP to log in

This ensures:
- **Single source of truth**
- **Token consistency**
- **Remote generator control**
- **No seed leakage to clients**

### 🕗 Trusted IP Long Session
IP whitelist is **not bypass**.  
It only extends session lifetime after successful TOTP:

- Untrusted IP: short session
- Trusted IP: long session
- First access always requires TOTP

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
- Private TOTP protocol (ZTL internal)
- Time drift tolerant
- 8-digit dynamic code or basic TOTP protocol
- 8-digit code does not compatible with third-party authenticator apps,but basic TOTP protocol can use with other TOTP clients
- Advantages:
  - No exposure of seed or internal materials
  - Cannot be imported, synced, or cloned externally
  - Fully controlled and bound by the ZTL service
  - Resistant to common TOTP-related leaks and misuse
  - Lightweight and zero third-party dependency
    
### Path-Specific TOTP Authentication (PathTokens)
- Support independent TOTP secrets for different URL paths or prefixes
- Paths ending with `/` → **prefix matching** (recommended for protecting entire directories, e.g., `/admin/`)
- Paths without trailing `/` → **exact matching**
- Form-based login sessions are bound to the authorized path scope
- Accessing other protected paths triggers re-authentication with the corresponding token
- Basic Auth remains stateless and validates per-request path-specific tokens
- Unmatched paths fall back to the global token (fully backward compatible)

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
- No IP trust without TOTP validation
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
Usage of ./zero-trust-lite:
  -L string
        Listen address
  -V    Show version and exit
  -adminpath string
        Admin path (random if empty)
  -backend string
        Backend URL
  -block string
        Block duration (default "5m")
  -c string
        Multi-instance config file
  -config string
        Multi-instance config file
  -debug
        Enable debug logging
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
        Path-specific TOTP token, format: /path/=SECRET (can be repeated)
  -token string
        TOTP secret
  -totp-mode string
        TOTP mode: '8' = legacy 8-digit only, 'auto' = support both standard 6-digit and legacy 8-digit (default "8")
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
