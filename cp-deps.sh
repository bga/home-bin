#!/bin/sh
set -eu 
set -o pipefail || true

bin=$1
toDir=$2
cp $(ldd $(where "$bin") | awk '{ print $3 }' | grep -F usr) "$toDir"
