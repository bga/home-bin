IN_F=$1
OUT_F=${2:-$IN_F-flash.bin} 
echo "$OUT_F" 
# SECTION='P3-P5 ro'
SECTION='A2 rw'

readSection() {
	SECTION=$1

	#  [Nr] Name              Type            Addr     Off    Size   ES Flg Lk Inf Al
	# ...
	# [ 7] P3-P5 ro          PROGBITS        00008080 0000b4 00015b 01  AX  0   0  1
	readelf -S "$IN_F" |
		grep "$SECTION" |
		awk -F 'PROGBITS' '{print $2}' |
		awk '{print "dd if='$IN_F' bs=1 skip=$[0x" $2 "] count=$[0x" $3 "]"}' |
		bash
}

(readSection 'A2 rw'; readSection 'P3-P5 ro') > "$OUT_F"
