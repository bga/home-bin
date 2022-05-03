#!/usr/bin/env ruby
# cat a.bin | hexToBin > a.hex
isFirstLine = true
while s = STDIN.read(80 / ("0xff,".size))
  STDOUT.write((isFirstLine ? "" : ",\n")  + s.split("").map { |str| "0x" + str.ord.to_s(16)}.join(","))
  isFirstLine = false
end