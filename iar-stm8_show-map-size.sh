buildProfile=${1:-Release}
tail -n 6 ${buildProfile}/List/*.map | head -n 3
