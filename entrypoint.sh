#!/bin/sh

# Global variables
DIR_CONFIG="/etc/v2ray"
DIR_RUNTIME="/usr/bin"
DIR_TMP="$(mktemp -d)"

# Write V2Ray configuration
cat << EOF > ${DIR_TMP}/heroku.json
{
     "inbounds": [
    {
      "port": 443,
      "protocol": "vless",
      "settings": {
        "udp": false,
        "clients": [
          {
            "id": "0931b1e3-a833-4566-9fe6-fc157f03b34f",
            "alterId": 0,
            "email": "t@t.tt",
            "flow": ""
          }
        ],
        "decryption": "none",
        "allowTransparent": false
      },
      "streamSettings": {
        "network": "ws",
        "security": "tls",
        "tlsSettings": {
          "allowInsecure": true,
          "serverName": "ltewap.tv189.com"
        },
        "wsSettings": {
          "path": "/",
          "headers": {
            "Host": "ltewap.tv189.com"
          }
        }
      }
    }
  ],
  "routing": {
    "domainStrategy": "IPIfNonMatch",
    "rules": []
  }
}
    "outbounds": [{
        "protocol": "freedom"
    }]
}
EOF

# Get V2Ray executable release
curl --retry 10 --retry-max-time 60 -H "Cache-Control: no-cache" -fsSL github.com/v2fly/v2ray-core/releases/latest/download/v2ray-linux-64.zip -o ${DIR_TMP}/v2ray_dist.zip
busybox unzip ${DIR_TMP}/v2ray_dist.zip -d ${DIR_TMP}

# Convert to protobuf format configuration
mkdir -p ${DIR_CONFIG}
${DIR_TMP}/v2ctl config ${DIR_TMP}/heroku.json > ${DIR_CONFIG}/config.pb

# Install V2Ray
install -m 755 ${DIR_TMP}/v2ray ${DIR_RUNTIME}
rm -rf ${DIR_TMP}

# Run V2Ray
${DIR_RUNTIME}/v2ray -config=${DIR_CONFIG}/config.pb
