#!/bin/sh

if [ $# != 1 ]; then
  echo "usage: notify-ip-change.sh domain_name"
  exit -1
fi

IP_CURRENT=$(dig $1 +short)
if [ $? != 0 ]; then
  IP_CURRENT=$(curl inet-ip.info)
fi

FILE_DIR="/etc/mydns/"
FILE_OLD="${FILE_DIR}old"

CMD="${FILE_DIR}notify-ip.sh"

if [ -f $FILE_OLD ]; then
  IP_OLD=$(cat $FILE_OLD)
  if [ $IP_CURRENT != $IP_OLD ]; then
    eval $CMD
  fi
else
  eval $CMD
fi
eval "echo $IP_CURRENT > $FILE_OLD"