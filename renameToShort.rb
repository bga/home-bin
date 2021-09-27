filePath = ARGV[0]
dirName = File.dirname(filePath)
baseName = File.basename(filePath)
realName, ext = baseName.split(".", 2)
ext = (ext) ? "." + ext : ""
shortRealName = realName.gsub(/([a-z])\w*/i, "\\1").gsub(/\s/, "")
p File.join(dirName, realName + ext), File.join(dirName, shortRealName + ext)
File.rename(File.join(dirName, realName + ext), File.join(dirName, shortRealName + ext))
