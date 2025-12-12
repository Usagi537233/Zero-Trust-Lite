# 大家好，阿拉乌萨奇。
  
## 作为有着几十台小鸡的黄色怪叫兔，探针是必不可少的。那么如此同时，方便运维的同时，必不可少的一样也是安全！安全！还是踏马的安全！
  
然后有人就会说，那我不开密码登录不就行了。
  
### 那么在家常便饭般的爆破下，要如何解决密码登录的安全问题，这就是今天的课题。

# 1、
先去 https://ipsafev2.537233.xyz 开设一个你的个人IP路径，牢记出现的path和token，下面会用到。当然如果你觉得好用的话，欢迎去 https://ipm.537233.xyz 升级专业版支持我一下，为爱发电。
那么很简单，我的KomariDashboard运行在25774的端口下，那我的Zero-Trust-Lite运行在25775的时候下。

# 2、
Zero-Trust-Lite的config.json如下
~~~
[
  {
    "name": "admin-panel",
    "listen": "127.0.0.1:25775",
    "backend": "http://127.0.0.1:25774",
    "token": "yourtoken",
    "key": "a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6q7r8s9t0u1v2w3x4y5z6a7b8c9d0e1f2",
    "wlsession": "168h", 
    "nmsession": "15m",
    "whitelisturl": "",
    "interval": 60,
    "failedtime": "5/2m",
    "block": "30m"
  }
]
~~~
- yourtoken用上面 https://ipsafev2.537233.xyz 注册后出现的token
- key：可以用以下命令生成：
 tr -dc 'a-z0-9' < /dev/urandom | head -c 64 来生成
- whitelisturl就是上面 https://ipsafev2.537233.xyz 注册后出现的path和token的 示例：https://ipsafev2.537233.xyz/yourpath/iplist?token=yourtoken

# 3、
此时此刻我们还要去nginx改一下反代路径
~~~
    location / {
        proxy_pass http://127.0.0.1:25775;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;

        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "Upgrade";

        # 禁用代理缓冲
        proxy_buffering off;

        # 允许大文件上传（50M）
        client_max_body_size 50M;
    }
~~~
## 如果你Nginx是在Cloudflare CDN 后面的话把
~~~
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
~~~
改为
~~~
        proxy_set_header X-Real-IP $http_cf_connecting_ip;
        proxy_set_header X-Forwarded-For $http_cf_connecting_ip;
~~~
## 当然这个就按照你自己的实际情况来决定。

# 4、
### 然后此时此刻，你再访问你的Komari探针页面将会出现验证，你再访问 https://ipsafev2.537233.xyz/yourpath/totp?token=yourtoken 后把得到的数字填入验证，就可以直接使用了，当然如果你访问用的IP
- 不在白名单中：每 "nmsession": "15m"（15 分钟）重新验证一次。
- 在白名单中："wlsession": "168h"（7 天）内同一设备自动续期。
  （开启隐私模式或清除 cookies 会触发重新验证）
 
 ## 当然，这两项都可以修改。

好了，这个时候你可能要问了，那我要如何展现我这么多台鸡给别人看，但是又能保护到自己的探针不被爆破呀？
我们下期见，下课！
