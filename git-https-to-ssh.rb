def debugPrint(*args) 
	# puts *args
end

def stderrPrint(*args) 
	STDERR.puts *args
end

def writeWrapper(&b)
	b.call()
end

Dir.glob("**/.git/config").each { |filePath|
	open(filePath, "r+t") { |f|
		debugPrint filePath
		oldText = f.read()
		text = oldText.gsub(/^(?<indent>\s*)(?<origString>url\s*\=\s*https\:\/\/github\.com\/(?<userName>[^\/]+?)\/(?<repoName>.+)\.git\s*)$/, "\\k<indent># \\k<origString>\n\\k<indent>url = git@github.com:\\k<userName>/\\k<repoName>.git")
		debugPrint text
		if(text != oldText)
			stderrPrint "updating #{ filePath }"
			writeWrapper {
				f.rewind()
				f.write(text)
			}
		end
		f.close()
	}
}
