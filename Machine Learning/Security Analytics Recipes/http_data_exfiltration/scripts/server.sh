#!/usr/bin/env bash

### Simple HTTP server to receive bytes over http. To be used in conjunction with client.sh to recieve random bytes and immiate a HTTP exfilfration signature.
#
# Usage: $0 <port>
#  - <port> defaults to 3333
#
# Ex. ./server.sh 5555
#
PORT=3333
if [ "$2" ]; then
  PORT=$2
fi

socat \
    TCP-LISTEN:$PORT,crlf,reuseaddr,fork \
    SYSTEM:"
        echo HTTP/1.1 200 OK;
        echo Content-Type\: text/plain;
        echo Content-Length\: 0;
        echo;
        echo;
    "
