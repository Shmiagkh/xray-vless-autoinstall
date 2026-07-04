#!/bin/bash

apt install -y curl mc htop nano qrencode

bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install

systemctl stop xray.service

uuid=$(xray uuid)

keys=$(xray x25519)

private_key=$(echo "$keys" | awk '/PrivateKey:/ {print $2}')
public_key=$(echo "$keys" | awk '/):/ {print $3}')

pass=$(openssl rand -base64 16)

shortid=$(openssl rand -hex 8)

ip=$(curl -s ifconfig.me)

cat <<EOL > /usr/local/etc/xray/config.json
{
  "inbounds": [{
    "port": 443,
    "protocol": "vless",
    "settings": {
      "clients": [{
        "id": "$uuid",
	"flow": "xtls-rprx-vision"
      }],
      "decryption": "none"
    },
    "streamSettings": {
      "network": "xhttp",
      "security": "reality",
      "realitySettings": {
        "show": false,
        "dest": "www.microsoft.com:443",
        "xver": 0,
        "serverNames": ["www.microsoft.com"],
        "privateKey": "$private_key",
        "shortIds": ["$shortid"]
      },
      "xhttpSettings": {
        "path": "/api/v1/data",
        "mode": "stream-one",
        "extra": {
          "xPaddingBytes": "100-1000"
        }
      }
    },
    "sniffing": {
      "enabled": true,
      "destOverride": ["http", "tls", "quic"]
    }
  }]
}
EOL

systemctl start xray.service

systemctl enable xray.service

echo " "
echo "vless://$uuid@$ip:443?security=reality&encryption=none&pbk=$public_key&headerType=none&fp=chrome&type=tcp&flow=xtls-rprx-vision&sni=www.microsoft.com&sid=$shortid#vless"

qrencode -t ansiutf8 "vless://$uuid@$ip:443?security=reality&encryption=none&pbk=$public_key&headerType=none&fp=chrome&type=tcp&flow=xtls-rprx-vision&sni=www.microsoft.com&sid=$shortid#vless"

