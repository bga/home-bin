#!/bin/sh
set -eu 
set -o pipefail || true

pathToFile=$1

git filter-branch --force --index-filter 'git rm --cached --ignore-unmatch '$pathToFile --prune-empty --tag-name-filter cat -- --all
