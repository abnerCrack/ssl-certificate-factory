#!/usr/bin/env bash

cd "$(dirname "${BASH_SOURCE[0]}")"
rm -rf out config
mkdir out config
mkdir config/newcerts
touch config/index.txt
echo 1000 > config/serial
echo '清理完成'
