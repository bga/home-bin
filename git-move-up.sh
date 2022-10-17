#!/bin/sh
set -eu -o pipefail || true

# [https://stackoverflow.com/a/5446061]

toDir=$1
time git filter-branch --index-filter $(echo 'git ls-files -s |
	sed "s-\t\"*-&TO_DIR/-" |
	GIT_INDEX_FILE=$GIT_INDEX_FILE.new git update-index --index-info && 
mv $GIT_INDEX_FILE.new $GIT_INDEX_FILE' | sed "s:TO_DIR:$toDir:") --tag-name-filter cat -- --all
