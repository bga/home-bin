#!/bin/sh
set -eu 
set -o pipefail || true

host=$1
set +u; delay=${2:-3}; set -u;

tempKeyPath=$(mktemp)
echo y | ssh-keygen -q -t rsa -b 2048 -N "" -f "$tempKeyPath"
while true; do 
	ssh -i "$tempKeyPath" -o ConnectionAttempts=20 -o PasswordAuthentication=no root@$host  || true
	sleep "$delay" 
done;
