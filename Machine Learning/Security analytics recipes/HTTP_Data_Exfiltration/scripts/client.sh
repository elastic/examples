#!/usr/bin/env bash

### Client side script to send random data over http to imitate an HTTP exfilfration signature.
### This script relies on a receiving server - this is provided through server.sh.
#
# Usage: $0 <server_host> [server_port]
#  - <server_host>. Required.
#  - <server_port> optional and defaults to 3333
#
# Ex. ./client.sh localhost
#

if [ -z "$1" ]
  then
    echo "No hostname supplied - Usage: $0 <hostname> [port]"
    exit 1
fi

HOST=$1

PORT=3333
if [ "$2" ]; then
  PORT=$2
fi

while true; do
    cmd=$(dd if=/dev/urandom bs=1 count=1k 2>/dev/null |  curl -s -X POST -H "Content-Type: text/plain" --data-binary @- $HOST:$PORT)
done