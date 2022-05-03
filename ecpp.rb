#!/usr/bin/env ruby
# require 'fileutils'
find = "findUnix"
fileName = File.join(Dir.pwd, ARGV[0])
currentDrive = $0[0 ... 2]

gccOptionsString = ((ARGV[1 ... ARGV.size] or [])
  .map {
    |v| 
    if(v.match(/\s/))
      '"' + v.gsub(/\"/, '""') + '"'
    else
      v
    end
  }
  .join(" ")
)
require "tmpdir"
tmpDirPath = Dir.mktmpdir
prefix = `node #{ currentDrive }/dependencyCopy/dependencyCopy.js #{ fileName } #{ (tmpDirPath + "/").gsub(/\//, "\\") }`
files = `#{ find } "#{ tmpDirPath }" -name "*.c" -or -name "*.cpp" -or -name "*.h"`.split("\n")
files.each {
  |file|
  `node #{ currentDrive }/p/safejs/cMod.node.js #{ file.gsub(/\//, "\\") } #{ file.gsub(/\//, "\\") }`
}
processedFileName = File.join(tmpDirPath, fileName.slice(prefix.size, fileName.size))
`gcc #{ processedFileName } #{ gccOptionsString }`
