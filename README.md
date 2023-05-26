# xray-vless-reality
Xray, VLESS_Reality模式

# 一键执行
```
apt update
apt install -y curl
```
```
bash <(curl -L https://github.com/crazypeace/xray-vless-reality/raw/main/install.sh)
```

# 打开BBR
```
sed -i '/net.ipv4.tcp_congestion_control/d' /etc/sysctl.conf
sed -i '/net.core.default_qdisc/d' /etc/sysctl.conf
echo "net.ipv4.tcp_congestion_control = bbr" >>/etc/sysctl.conf
echo "net.core.default_qdisc = fq" >>/etc/sysctl.conf
sysctl -p >/dev/null 2>&1
```

# 安装Xray beta版本
source: https://github.com/XTLS/Xray-install
```
bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install --beta
```

# 获得 x25519 公私钥
```
xray x25519
```
私钥会在服务端用到，公钥会在客户端用到。

# 获得 UUID
```
xray uuid
```

# 定一个你喜欢的网站 (SNI)
比如，`www.microsoft.com`


# 选一个你喜欢的指纹 (Fingerprint)
可选项见此：https://xtls.github.io/en/config/transport.html 不想选，就用`random`
![image](https://github.com/crazypeace/xray-vless-reality/assets/665889/89cdc776-95b4-4003-b89f-ac5a48bd1da5)


# Reality 协议中规定了 ShortId, SpiderX
个人使用可以不管，留空


# 配置 /usr/local/etc/xray/config.json
```
{ // VLESS + Reality
  "log": {
    "loglevel": "warning"
  },
  "inbounds": [
    {
      "listen": "0.0.0.0",
      "port": 443,    // 理论上可以随便改，不过从访问梯子的行为上，我个人认为使用443比较合适
      "protocol": "vless",
      "settings": {
        "clients": [
          {
            "id": "你的UUID",    // ***改这里
            "flow": "xtls-rprx-vision"
          }
        ],
        "decryption": "none"
      },
      "streamSettings": {
        "network": "tcp",
        "security": "reality",
        "realitySettings": {
          "show": false,
          "dest": "你喜欢的网站:443",    // 如 www.microsoft.com:443
          "xver": 0,
          "serverNames": [
            "你喜欢的网站"    // 如 www.microsoft.com
          ],
          "privateKey": "你的私钥",    // ***改这里
          "shortIds": [
            ""    // 可以留空
          ]
        }
      },
      "sniffing": {
        "enabled": true,
        "destOverride": [
          "http",
          "tls"
        ]
      }
    }
  ],
  "outbounds": [
    {
      "protocol": "freedom",
      "tag": "direct"
    },
    {
      "protocol": "blackhole",
      "tag": "block"
    }
  ],
  "dns": {
    "servers": [
      "8.8.8.8",
      "1.1.1.1",
      "2001:4860:4860::8888",
      "2606:4700:4700::1111",
      "localhost"
    ]
  },
  "routing": {
    "domainStrategy": "IPIfNonMatch",
    "rules": [
      {
        "type": "field",
        "ip": [
          "geoip:private"
        ],
        "outboundTag": "block"
      }
    ]
  }
}
```

# 如果是 IPv6 only 的小鸡，用 WARP 添加 IPv4 出站能力
```
bash <(curl -L git.io/warp.sh) 4
```

# Uninstall
```
bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ remove --purge
```

## 用你的STAR告诉我这个Repo对你有用 Welcome STARs! :)

[![Stargazers over time](https://starchart.cc/crazypeace/xray-vless-reality.svg)](https://starchart.cc/crazypeace/xray-vless-reality)
