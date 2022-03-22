#!/bin/sh
set -eu -o pipefail

keyFile=$1
host=$2
cat "$keyFile" | ssh "$host" "umask 077 && mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys"
