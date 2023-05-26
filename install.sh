# 等待1秒, 避免curl下载脚本的打印与脚本本身的显示冲突, 吃掉了提示用户按回车继续的信息
sleep 1

echo -e "                     _ ___                   \n ___ ___ __ __ ___ _| |  _|___ __ __   _ ___ \n|-_ |_  |  |  |-_ | _ |   |- _|  |  |_| |_  |\n|___|___|  _  |___|___|_|_|___|  _  |___|___|\n        |_____|               |_____|        "
red='\e[91m'
green='\e[92m'
yellow='\e[93m'
magenta='\e[95m'
cyan='\e[96m'
none='\e[0m'
_red() { echo -e ${red}$*${none}; }
_green() { echo -e ${green}$*${none}; }
_yellow() { echo -e ${yellow}$*${none}; }
_magenta() { echo -e ${magenta}$*${none}; }
_cyan() { echo -e ${cyan}$*${none}; }

error() {
    echo -e "\n$red 输入错误! $none\n"
}

pause() {
    read -rsp "$(echo -e "按 $green Enter 回车键 $none 继续....或按 $red Ctrl + C $none 取消.")" -d $'\n'
    echo
}

# 说明
echo
echo -e "$yellow此脚本仅兼容于Debian 10+系统. 如果你的系统不符合,请Ctrl+C退出脚本$none"
echo -e "可以去 ${cyan}https://github.com/crazypeace/xray-vless-reality${none} 查看脚本整体思路和关键命令, 以便针对你自己的系统做出调整."
echo -e "有问题加群 ${cyan}https://t.me/+ISuvkzFGZPBhMzE1${none}"
echo "----------------------------------------------------------------"

pause

# 准备工作
apt update
apt install -y curl sudo gawk jq qrencode

# Xray官方安装脚本
echo
echo -e "${yellow}Xray官方安装脚本$none"
echo "----------------------------------------------------------------"
bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install --beta

# 本机IP
echo
echo -e "如果你的小鸡是${magenta}双栈(同时有IPv4和IPv6的IP)${none}，请选择你把v2ray搭在哪个'网口'上"
echo "如果你不懂这段话是什么意思, 请直接回车"
read -p "$(echo -e "Input ${cyan}4${none} for IPv4, ${cyan}6${none} for IPv6:") " netstack

if [[ $netstack == "4" ]]; then
    # ip=$(curl -4s https://api.myip.la)
    ip=$(curl -4s https://www.cloudflare.com/cdn-cgi/trace | grep ip= | sed -e "s/ip=//g")
elif [[ $netstack == "6" ]]; then
    # ip=$(curl -6s https://api.myip.la)
    ip=$(curl -6s https://www.cloudflare.com/cdn-cgi/trace | grep ip= | sed -e "s/ip=//g")
else
    # ip=$(curl -s https://api.myip.la)
    ip=$(curl -s https://www.cloudflare.com/cdn-cgi/trace | grep ip= | sed -e "s/ip=//g")
fi

# x25519公私钥
tmp_key=$(xray x25519)
private_key=$(echo ${tmp_key} | awk '{print $3}')
public_key=$(echo ${tmp_key} | awk '{print $6}')

# v2ray UUID
v2ray_id=$(echo $public_key | head -c 16 | xargs xray uuid -i)

# 目标网站
domain="www.microsoft.com"

# 指纹 Fingerprint
fingerprint="random"

# 配置config.json
cat > /usr/local/etc/xray/config.json <<-EOF
{
    "log": {
        "loglevel": "warning"
    },
    "inbounds": [
        {
            "listen": "0.0.0.0",
            "port": 443, # ***
            "protocol": "vless",
            "settings": {
                "clients": [
                    {
                        "id": "$v2ray_id", # ***uuid
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
                    "dest": "$domain:443", # ***
                    "xver": 0,
                    "serverNames": ["$domain"], # ***
                    "privateKey": "$private_key", # ***
                    "shortIds": [""] # ***
                }
            },
            "sniffing": {
                "enabled": true,
                "destOverride": ["http", "tls"]
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
EOF

# 重启 V2Ray
echo
echo -e "$yellow重启 V2Ray$none"
echo "----------------------------------------------------------------"
service v2ray restart

echo
echo "---------- V2Ray 配置信息 -------------"
echo -e "$green ---提示..这是 VLESS reality 服务器配置--- $none"
echo -e "$yellow 地址 (Address) = $cyan${ip}$none"
echo -e "$yellow 端口 (Port) = ${cyan}443${none}"
echo -e "$yellow 用户ID (User ID / UUID) = $cyan${v2ray_id}$none"
echo -e "$yellow 流控 (Flow) = ${cyan}xtls-rprx-vision${none}"
echo -e "$yellow 加密 (Encryption) = ${cyan}none${none}"
echo -e "$yellow 传输协议 (Network) = ${cyan}tcp$none"
echo -e "$yellow 伪装类型 (header type) = ${cyan}none$none"
echo -e "$yellow 底层传输安全 (TLS) = ${cyan}reality$none"
echo -e "$yellow SNI = ${cyan}$domain$none"
echo -e "$yellow Fingerprint = ${cyan}$fingerprint$none"
echo -e "$yellow PublicKey = ${cyan}${public_key}$none"
echo -e "$yellow ShortId = ${cyan}$none"
echo -e "$yellow SpiderX = ${cyan}$none"
echo
echo "---------- VLESS Reality URL ----------"
vless_reality_url="vless://${v2ray_id}@${ip}:443?encryption=none&flow=xtls-rprx-vision&security=reality&sni=${domain}&fp=${fingerprint}&pbk=${public_key}&type=tcp#VLESS_R_${ip}"
echo -e "${cyan}${vless_reality_url}${none}"
echo
sleep 3
echo "以下两个二维码完全一样的内容"
qrencode -t UTF8 $vless_reality_url
qrencode -t ANSI $vless_reality_url
echo
echo "---------- END -------------"
echo "以上节点信息保存在 ~/_vless_reality_url_ 中"

# 节点信息保存到文件中
echo $vless_reality_url > ~/_vless_reality_url_
echo "以下两个二维码完全一样的内容" >> ~/_vless_reality_url_
qrencode -t UTF8 $vless_reality_url >> ~/_vless_reality_url_
qrencode -t ANSI $vless_reality_url >> ~/_vless_reality_url_
