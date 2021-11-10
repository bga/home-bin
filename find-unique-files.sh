#!/usr/bin/bash
set -eu -o pipefail

DIR1=$1
DIR2=$2

comm -23 \
	<(find "$DIR1" "$DIR2" -type f | sort) \
	<(jdupes -r -T -T "$DIR1" "$DIR2"  | xargs -d $'\n' cygpath -u {}\; | awk -v p1="$DIR1" -v p2="$DIR2" '$0 ~ p1 && $0 ~ p2'  RS="\n\n" ORS="\n\n" | sort)
