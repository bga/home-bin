#!/usr/bin/env ruby

# echo foo | replace-words foo hello # hello
# echo Foo | replace-words foo hello # Hello
# echo FOO | replace-words foo hello # HELLO

# echo FOO_BAR | replace-words foo-bar hello-world # HELLO_WORLD
# echo fooBar | replace-words foo-bar hello-world # helloWord
# echo foo_bar | replace-words foo-bar hello-world # hello_word
# echo foo-bar | replace-words foo-bar hello-world # hello-word


# echo foo-bar Java | replace-words foo-bar hello-world java kotlin # hello-word Kotlin

progName = File.basename($0, File.extname($0))

help = """
#{ progName } [search-word replace-word]...  
""".strip()

def debugPrint(&b)
	# STDERR.puts(b.call().inspect())
end

dieWithHelp = proc { |exitMsg|
	STDERR.puts(exitMsg)
	STDERR.puts(help)
	
	exit(1)
}

ARGV.size % 2 == 0 or dieWithHelp.call("missed replace-word")

class String
	def words_raw()
		if(nil)
		elsif(self.index("-"))
			self.split(/\-+/)
		elsif(self.index("_"))
			self.split(/\_+/)
		else
			[self]
		end
	end
	
	def words()
		self.words_raw.map { |w| w.strip().downcase() }
	end
end

transforms = [
	# capitalCamelCase
	proc { |words|
		words.map { |w| w.capitalize() }.join("")
	}, 
	# camelCase
	proc { |words|
		x = words
		x[0] + x[1 .. x.size].map { |w| w.capitalize() }.join("")
	}, 
	# upperSnakeCase
	proc { |words|
		words.join("_").upcase()
	}, 
	# lowerSnakeCase
	proc { |words|
		words.join("_").downcase()
	}, 
	# lowerDashCase
	proc { |words|
		words.join("-").downcase()
	}
]

replaceMap = (ARGV
	.map { |w| w.words }
	.each_slice(2).to_a.map { |pair|
		searchWord = pair[0]
		replaceWord = pair[1]
		
		transforms.map { |t| [t.call(searchWord), t.call(replaceWord)] }
	}
	.flatten(1)
	.uniq()
)

debugPrint { replaceMap }

s = nil
# while(s = STDIN.readline()) do
# while gets() do
	# s = $_ 
# FIXME dont change EOL
STDIN.each_line do |s|
	debugPrint { s }
	replaceMap.each { |pair|
		s = s.gsub(pair[0], pair[1])
	}
	STDOUT.write(s)
end
