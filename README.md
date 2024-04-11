# xray-vless-reality
Xray, VLESS_Reality模式 极简一键脚本

# 说明 
这个一键脚本超级简单。有效语句8行(其中BBR 5行, 安装Xray 1行, 生成x25519公私钥 1行，生成UUID 1行)+Xray配置文件69行(其中你需要修改4行), 其它都是用来检验小白输入错误参数或者搭建条件不满足的。

你如果不放心开源的脚本，你可以自己执行那8行有效语句，再修改配置文件中的4行，也能达到一样的效果。

Reality底层是TCP直连，如果你的VPS已经被墙，那肯定用不了。出门左转 https://github.com/crazypeace/v2ray_wss

# 一键安装
```
apt update
apt install -y curl
```
```
bash <(curl -L https://github.com/crazypeace/xray-vless-reality/raw/main/install.sh)
```

脚本中很大部分都是在校验用户的输入。其实照着下面的步骤自己配置就行了。

<details>
    <summary>具体手搓步骤 (点击展开)</summary>

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


# 生成 x25519 公钥和私钥
```
xray x25519
```
私钥会在服务端用到，公钥会在客户端用到。


# 生成 UUID
```
xray uuid
```

# 选一个你喜欢的网站 (SNI)
比如，`learn.microsoft.com`


# 选一个你喜欢的指纹 (Fingerprint)
可选项见此：https://xtls.github.io/en/config/transport.html 不想选，就用`random`
![image](https://github.com/crazypeace/xray-vless-reality/assets/665889/89cdc776-95b4-4003-b89f-ac5a48bd1da5)


# Reality 协议中定义了 ShortId, SpiderX
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
          "dest": "你喜欢的网站:443",    // ***如 learn.microsoft.com:443
          "xver": 0,
          "serverNames": ["你喜欢的网站"],    //***如 learn.microsoft.com
          "privateKey": "你的**私钥**",    // ***改这里
          "shortIds": [""]    // 可以留空
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
        "ip": ["geoip:private"],
        "outboundTag": "block"
      }
    ]
  }
}
```

# 客户端参数配置
脚本最后会输出VLESS链接，方便你导入翻墙客户端。

如果你是手搓自建，请参考下图配置。特别需要注意的是，客户端用的是**公钥**。和服务端用的**私钥**不一样。
![image](https://github.com/crazypeace/xray-vless-reality/assets/665889/52a943aa-ba8b-4a4a-a7ca-21c75807d678)

如果你是手搓VLESS链接，那么参考：https://github.com/XTLS/Xray-core/discussions/716
如 `vless://${xray_id}@${ip}:443?encryption=none&flow=xtls-rprx-vision&security=reality&sni=${domain}&fp=${fingerprint}&pbk=${public_key}&type=tcp#VLESS_R_${ip}`

# 如果是 IPv6 only 的小鸡，用 WARP 添加 IPv4 出站能力
```
bash <(curl -L git.io/warp.sh) 4
```

</details>

# Uninstall
```
bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ remove --purge
```

# 私货
对于喜欢V2rayN PAC模式的朋友，欢迎使用支持Reality的 [v2rayN-3.29-VLESS](https://github.com/crazypeace/v2rayN-3.29-VLESS)
![v2rayN_2022-07-20_22-02-43](https://user-images.githubusercontent.com/665889/180002616-c2c6da3c-78b0-4f46-8fa9-34021590646f.png)


# 脚本支持带参数运行
```
bash <(curl -L https://github.com/crazypeace/xray-vless-reality/raw/main/install.sh) <netstack> [port] [domain] [UUID]
```

其中, 

`netstack` 6 表示 IPv6 入站; 4 表示 IPv4 入站.

`port` 端口. 不写的话, 默认443

`domain` 你指定的网站域名. 不写的话, 默认 learn.microsoft.com

`UUID` 你的UUID. 不写的话, 自动生成

例如,
```
bash <(curl -L https://github.com/crazypeace/xray-vless-reality/raw/main/install.sh) 6
bash <(curl -L https://github.com/crazypeace/xray-vless-reality/raw/main/install.sh) 6 443
bash <(curl -L https://github.com/crazypeace/xray-vless-reality/raw/main/install.sh) 6 443 learn.microsoft.com
bash <(curl -L https://github.com/crazypeace/xray-vless-reality/raw/main/install.sh) 6 443 learn.microsoft.com 1b0b723f-0544-4f9c-8df8-2b8975c5e47a
```


# 用你的STAR告诉我这个Repo对你有用 Welcome STARs! :)
[![Stargazers over time](https://starchart.cc/crazypeace/xray-vless-reality.svg)](https://starchart.cc/crazypeace/xray-vless-reality)
