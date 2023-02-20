#!/bin/sh
set -eu 
set -o pipefail || true

scp "$@" rtorrent-add@s0.lan:~/
