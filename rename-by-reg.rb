#!/usr/bin/env ruby

programName = File.basename($0)

help = [
	"#{ programName } [--help] [--dry-run] [-v | --verbose] reg sub [- | file...]", 
	"", 
	"#{ programName } '\\-\\d+\\.mp3' '.mp3' *.mp3", 
	"ls *.mp3 | #{ programName } '\\-\\d+\\.mp3' '.mp3' -", 
].join("\n")

if(ARGV.size == 0)
	puts help
	exit
end

argvPos = 0

isDryRun = false
isVerbose = false

userPrintNoEol = proc { |*args|
	if(isVerbose)
		STDOUT.write *args
	end
}

userPrintWithEol = proc { |*args|
	userPrintNoEol(*args, "\n")
}

def die(str)
	STDERR.puts(str)
	exit(1)
end

while(ARGV[argvPos] && ARGV[argvPos].slice(0, 1) == "-")
	opt = ARGV[argvPos]
	if(opt == "--dry-run")
		isDryRun = true
		argvPos += 1
	elsif(opt == "-v" || ARGV[argvPos] == "--verbose")
		isVerbose = true
		argvPos += 1
	elsif(opt == "-h" || ARGV[argvPos] == "--help")
		puts help
		exit(0)
	else
		die("unknown option #{ opt }")
	end
end

regStr = ARGV[argvPos] or die("missed reg")
argvPos += 1

sub = ARGV[argvPos] or die("missed sub")
argvPos += 1

reg = Regexp.new(regStr)

readNext = nil
if(ARGV[argvPos] == "-")
	readNext = proc { || x = STDIN.gets(); x && x.strip() }
	argvPos += 1
else
	readNext = proc { || x = ARGV[argvPos]; argvPos += 1; x }
end


line = nil
# while(fileName = STDIN.read())
while(fileName = readNext.call())
	newFileName = fileName.sub(reg, sub)
	userPrintNoEol.call "#{ fileName } -> #{ newFileName }" 
	if(newFileName != fileName && !isDryRun)
		begin
			File.rename(fileName, newFileName)
		rescue SystemCallError => e
			userPrintNoEol " failed"
		end
	end
	userPrintNoEol.call "\n"
end
