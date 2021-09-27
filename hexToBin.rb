# cat a.hex | hexToBin > a.bin
STDOUT.binmode()
STDOUT.write(STDIN.read().split(",").map { |str| str.to_i(16).chr }.join(""))
