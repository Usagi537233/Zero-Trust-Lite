# Zero-Trust-Lite

A lightweight Zero Trust middleware providing **TOTP verification** + **trusted IP long session**, designed for self-hosted services, internal dashboards, and private tools.

Unlike normal TOTP implementations, this project uses a **remote TOTP provider binding model**:

> **TOTP is generated at:**  
> Users must create a token and visit:
> https://ipsafev2.537233.xyz/  
> using a user-owned `token`, shared by both the remote TOTP page and this middleware.
> https://ipsafev2.537233.xyz/yourpath/totp?token=YourToken

![image](./image.png)![image1](./image1.png)

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
- **TOTP as the core trust mechanism**
- No implicit network trust
- Every access path is verified
- Short session validity by default

### 🔐 Strong Authentication
- RFC 6238 TOTP implementation
- HMAC-SHA1
- Time drift tolerant
- 8 digit

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

Not a full Zero Trust replacement for:
- MFA device binding
- Device posture check
- Continuous session scoring
- Internal lateral movement detection

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
zero-trust-lite:
  -L string
        Listen address
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
  -listen string
        Listen address
  -nmsession string
        Normal session duration (default "30s")
  -token string
        TOTP secret
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
curl https://token:12345678@your-domain.com
~~~
