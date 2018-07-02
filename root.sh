#!/usr/bin/env bash
cd "$(dirname "${BASH_SOURCE[0]}")"

if [ -f "out/root.cert.pem" ]; then
    echo 根证书已存在!.
    exit 1
fi

if [ ! -d "out" ]; then
    bash flush.sh
fi

# 生成根证书
openssl req -config ca.cnf \
    -newkey rsa:2048 -nodes -keyout out/root.key.pem \
    -new -x509 -days 7300 -out out/root.cert.pem \
    -subj "/C=CN/ST=Guangdong/L=Guangzhou/O=Fishdrowned/CN=Fishdrowned ROOT CA"

# 生成私钥
openssl genrsa -out "out/cert.key.pem" 2048
