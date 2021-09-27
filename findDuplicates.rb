#!/usr/local/bin/ruby -w

if(ARGV.index("--help") || ARGV.index("-h"))
  puts <<~HELP
    Usage: #{ File.basename(__FILE__) } [DIR_GLOB or `pwd`/*.*]
    Find duplicates by DIR_GLOB.

    Options:
    \t-h, --help\t\tShow this output
    \t-d, --delete\t\tDelete duplicates
  HELP
end

i = 0
isDelete = (ARGV[i] == "-d" || ARGV[i] == "--delete") && (i += 1)
# isHelp = (ARGV[i] == "-h" || ARGV[i] == "--help") && (i += 1)

fileMask = ARGV[i] || "#{ Dir.pwd() }/**/*.*"
hashCmd = "sha1sum"

def log(*args)
  0 or STDERR.write(args.join(", ") + "\n")
end

files = Dir.glob(fileMask)
log files

i = 0
hashesMap = {  }
loop {
  if(i == files.size)
    break
  end
  file = files[i]
  if(!File.directory?(file))
    # typical output - { 848371fad27fc2781582e4654b7b60585bb50103 *file.pdf } - so split
    hash = `#{ hashCmd } "#{ file }"`.split(/\s+/)[0]

    if(hashesMap.key?(hash))
      puts "#{ hashesMap[hash] } == #{ file }"
      if(isDelete)
        File.delete(file)
        puts "rm #{ file }"
      else

      end
    else
      hashesMap[hash] = file
    end
  end
  i += 1
}
