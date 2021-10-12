#!/bin/sh
set -eu -o pipefail

curl --insecure -F "clbin=<-" https://clbin.com/ 
