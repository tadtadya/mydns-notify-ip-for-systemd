#!/bin/sh

# usage check
if [ $# != 1 ]; then
  echo "usage: notify-ip.sh user:password"
  exit -1;
fi

# notify ip to MyDNS
curl -s -u $1 https://ipv4.mydns.jp/login.html
# curl -s -u $1 https://ipv6.mydns.jp/login.html
