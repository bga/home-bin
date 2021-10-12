#!/bin/sh
set -eu -o pipefail

# pdfCutPages from.pdf 2-3 [to.pdf || from_2-3.pdf]

DOCUMENT=$1
STARTPAGE_DASH_STOPPAGE=$2
OUTFILE=${3:-${DOCUMENT/%.pdf/_$STARTPAGE_DASH_STOPPAGE.pdf}}

# --linearize "$DOCUMENT" 
qpdf --empty --pages "$DOCUMENT" "$STARTPAGE_DASH_STOPPAGE" -- "$OUTFILE"
