#!/usr/bin/env ruby

require "Set"

selfName = File.basename($0, File.extname($0)) 
help = """
#{selfName} template [tokensFile || -]
\ttemplate example \"s[X] + 2 * s[Y]\" where all uppercase vars will be replaced to random numbers
""".strip()

def debugPrint(*args)
	STDERR.puts(*args)
end

printHelpAndDie = proc {
	puts(help)
	exit(1)
}


def userPrint(*args)
	puts(*args)
end

tml = ARGV[0] or printHelpAndDie.call()
tokensFilePath = (ARGV[1] or "-")

debugPrint tokensFilePath

tokens = ((tokensFilePath == "-") ? STDIN : open(tokensFilePath, "rt")).each_line.to_a().map { |v| v.strip() }.select { |v| 0 < v.size }.uniq()

debugPrint tokens.join("\n")

# [https://stackoverflow.com/a/6075237]
safeEval = proc { |code|
  $SAFE = 1  # change level only inside this proc
  eval(code)
}

def strlen(s)
	s.size
end
def S8(n)
	n % 2 ** 8
end
def S16(n)
	n % 2 ** 16
end
def S32(n)
	n % 2 ** 32
end
def U8(n)
	n % 2 ** 8
end
def U16(n)
	n % 2 ** 16
end
def U32(n)
	n % 2 ** 32
end

index = 0
# hereStringMarker = "GRBKJVCT64CJIUGVV"
hereStringMarker = "TEST"
varNames = []
codeBody = tml.gsub(/\b([A-Z]+|_)\b/) { |all| m = $& 
	varName = m[0]
	if(varName == "_")
		varName = "seq#{ index }"
		index += 1
	else
		varName = "v#{ varName }"
	end
	varNames.push(varName)
	"#{ varName }"
}

code = "proc { |s, #{ varNames.join(", ") }| 
	$SAFE = 1
	#{ codeBody }
}
"

debugPrint varNames
debugPrint code

userFn = nil
begin
	userFn = eval(code)
rescue Exception => ex
	userPrint "Failed to compile tml\n#{ ex }"
end

tokensLimitSize = tokens.map { |v| v.size }.min

debugPrint "tokensLimitSize", tokensLimitSize

class Random
	def random_array(size, maxValue)
		(0...size).map { |_| self.rand(maxValue) }
	end
	def random_array_nonDup(size, maxValue)
		# (0...maxValue).to_a.shuffle(self).slice(0, size)
		(0...maxValue).to_a.shuffle().slice(0, size)
	end
end

calcHash = proc { |token, *vars|
	userFn.call(token.chars.map { |ch| ch.ord }, *vars)
}

rng = Random.new()
tryCount = 0
tryCountMax = 9999
ret = nil
varsGenerator = (0...tokensLimitSize).to_a.permutation(varNames.size)
loop {
	tryCount += 1
	# if(tryCountMax <= tryCount)
		# break
	# end
	
	# vars = (0...varNames.size).map { |_| rng.rand(tokensLimitSize) }
	# vars = rng.random_array_nonDup(varNames.size, tokensLimitSize)
	vars = nil
	begin
		vars = varsGenerator.next()
	rescue StopIteration => ex
		break
	end
	debugPrint "vars", vars.inspect()
	
	hashesSet = Set.new()
	i = 0
	loop {
		token = tokens[i]
		# hash = userFn.call(token.chars.map { |ch| ch.ord }, *vars)
		hash = calcHash.call(token, *vars)
		# debugPrint "token", token, "hash", hash
		# stop if hash already in set
		if(hashesSet.add?(hash) == nil)
			break
		end

		i += 1
		if(tokens.size <= i)
			break
		end
	}
	
	# seccess
	if(tokens.size <= i)
		ret = vars
		break
	end
	
}

if(ret == nil)	
	exit(1)
end

if(1)
	userPrint ret.join(" ")
end

userFnSubst = proc { |vars|
	codeBodyWithVars = codeBody
	varNames.each_with_index { |varName, i|
		codeBodyWithVars = codeBodyWithVars.gsub(Regexp.new("\\b#{ Regexp.escape(varName) }\\b"), vars[i].to_s())
	}
	codeBodyWithVars
}
if(1)
	userPrint userFnSubst.call(ret)
end

if(nil)
	userPrint tokens.map { |token|
		"#{ token }\t#{ calcHash.call(token, *ret) }"
	}.join("\n")
end

if(1)
	userPrint [
		"int hash = #{ userFnSubst.call(ret) }", 
		"switch(hash) {",
		*tokens.map { |token|
			"\tcase(#{ calcHash.call(token, *ret) }): //# #{ token }"
		}, 
		"\tdefault:", 
		"}"
	].join("\n")
end

exit(0)
