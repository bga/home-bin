#!/bin/sh
set -eu 
set -o pipefail || true

echo | gcc -v -x c++ -c -
