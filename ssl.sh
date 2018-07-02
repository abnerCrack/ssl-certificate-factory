#!/usr/bin/env bash

if [ -z "$1" ]
then
    echo
    echo '自动生成自签名证书'
    echo
    echo '用法 : ./cert.sh example.com'
    echo '                      自动生成 *.example.com的域名证书,支持泛域名解析'
    exit;
fi

SAN=""
for var in "$@"
do
    SAN+="DNS:*.${var},DNS:${var},"
done
SAN=${SAN:0:${#SAN}-1}


# 进入Shell根目录
cd "$(dirname "${BASH_SOURCE[0]}")"

# Generate root certificate if not exists
if [ ! -f "out/root.cert.pem" ]; then
    bash root.sh
fi

# 创建域名文件夹
# BASE_DIR="out/$1"
DIR="out/$1"
# TIME=`date +%Y%m%d-%H%M`
# DIR="${BASE_DIR}/${TIME}"
mkdir -p ${DIR}

# 创建CSR 请求文件
openssl req -new -out "${DIR}/$1.csr.pem" \
    -key out/cert.key.pem \
    -reqexts SAN \
    -config <(cat ca.cnf \
        <(printf "[SAN]\nsubjectAltName=${SAN}")) \
    -subj "/C=CN/ST=Guangdong/L=Guangzhou/O=Self/OU=$1/CN=*.$1"

# 生成证书
openssl ca -config ./ca.cnf -batch -notext \
    -in "${DIR}/$1.csr.pem" \
    -out "${DIR}/$1.cert" \
    -cert ./out/root.cert.pem \
    -keyfile ./out/root.key.pem

# 生成软连接
cat "${DIR}/$1.cert" ./out/root.cert.pem > "${DIR}/$1.cert.pem"
ln -snf "../cert.key.pem" "${DIR}/$1.key.pem"
ln -snf "../root.cert.pem" "${DIR}/root.cert.pem"

rm -rf "out/$1/$1.cert"
rm -rf "out/$1/$1.csr.pem"

rm -rf "out/cert.key.pem"
rm -rf "out/root.cert.pem"
rm -rf "out/root.key.pem"


# 输出证书
echo
echo "证书输出在:"

LS=$([[ `ls -help | grep '\-\-color'` ]] && echo "ls --color" || echo "ls -G")

# ${LS} -la `pwd`/${BASE_DIR}/*.*
