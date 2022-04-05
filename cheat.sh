#!/bin/sh
set -eu -o pipefail

keyword=$1
curl https://cheat.sh/"$keyword"
