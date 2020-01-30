#!/bin/sh

if [ $# != 1 ]; then
  echo "usage: notify-ip.sh user:password"
  exit -1;
fi

curl -s -u $1 https://ipv4.mydns.jp/login.html
# curl -s -u $1 https://ipv6.mydns.jp/login.html
