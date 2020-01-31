#!/bin/sh

# usage check
if [ $# != 2 ]; then
  echo "usage: notify-ip.sh user:password domain_name"
  exit -1
fi

# compare ip address
IP_CURRENT=$(dig $2 +short)
if [ $? != 0 ]; then
  IP_CURRENT=$(curl inet-ip.info)
fi

FILE_DIR="/etc/mydns/"
FILE_OLD="${FILE_DIR}old-$2"

CMD="${FILE_DIR}notify-ip.sh $1"

# exec notify ip shell
if [ -f $FILE_OLD ]; then
  IP_OLD=$(cat $FILE_OLD)
  if [ $IP_CURRENT != $IP_OLD ]; then
    eval $CMD
  fi
else
  eval $CMD
fi
eval "echo $IP_CURRENT > $FILE_OLD"