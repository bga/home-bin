#!/usr/bin/env ruby
i = 0
isDryRun = false
if(ARGV[i] == "--dry-run")
	isDryRun = true
end
srcDirPath = ARGV[i++]
destDirPath = ARGV[i++]

def getAllSymlins(path)
	Dir.glob(File.join(path, "**/*")).select { |f| File.symlink?(f) }.map { |f| [f, File.readlink(f)] }.to_h
end

srcAll = getAllSymlins(srcDirPath)
destAll = getAllSymlins(destDirPath)

srcAll.each { |srcFilePath|
	if(destAll[srcFilePath] == srcAll[srcFilePath])
}
