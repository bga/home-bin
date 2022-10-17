#!/bin/sh
set -eu 
set -o pipefail || true

file=$1
shift

outFile=$TEMP/$file.exe
echo $outFile

echo "#define BGA__TESTRUNNER_ON
#include \"${file}\" 

int main(int argc, const char* argv[]) {
  return testRunnerMain(argc, argv);
}" | g++ -x c++ - -I/e/p/!cpp/include -Wall -Wextra -Wcast-qual -Wsign-conversion "$@" -o "$outFile" && $outFile
