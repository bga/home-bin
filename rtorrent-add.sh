#!/bin/env bash
set -eu 
set -o pipefail || true

while [ $# -gt 0 ]; do
	file=$1
	shift

	chmod g+r "$file"
	scp -B -p -O -F ~/bin/emptyfile -P 37422 -i ~/.ssh/s0.lan-rtorrent_add-id_ed25519 "$file" rtorrent-add@bga.ind.in:~/
done
