#!/bin/sh
set -eu -o pipefail

# . github.com/void-linux/void-packages
# . github.com/void-linux/void-packages/
# . https://github.com/void-linux/void-packages/
# . --tar https://github.com/void-linux/void-packages/
# . --zip https://github.com/void-linux/void-packages/
# . https://github.com/void-linux/void-packages/ master

format=archive; formatExt=.zip
if [ $1 == --tar ]; then format=tarball; formatExt=; shift; fi
if [ $1 == --zip ]; then format=archive; formatExt=.zip; shift; fi

repoUrl=$1
set +u; branch=${2:-master}; set -u

repoUrl=${repoUrl%/}/
repoUrl=https://${repoUrl#https://}

curl -Lf# "${repoUrl}${format}/${branch}${formatExt}" 
