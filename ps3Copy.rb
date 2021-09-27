#
# ps3Copy.rb Downloads\BCES0001\ f:\GAMES\ 
#  => f:\GAMES\BCES0001\ or  f:\GAMES\_BCES0001\ if splitted files were
#   

srcFolderPath = ARGV[0].gsub("\\", File::SEPARATOR)
destFolderPath = ARGV[1].gsub("\\", File::SEPARATOR)

maxFat32FileSize = 4 * (1 << 10) ** 3 - 4 * (1 << 10)

require("Filesize")
require("colorize")

yes = !nil
no = !!nil

def log(msg)
  puts "[#{ Time.now() }] #{ msg }"
end
def warning(msg)
  puts "[#{ Time.now() }] #{ msg }".red
end
def debug(msg)
  puts msg.to_s.magenta
end

class String
  def toWindowsFilePathStyle()
    self.gsub(File::SEPARATOR, "\\")
  end
end

class Object
  def with(&f)
    f.call(self)
  end  
end

class Dir
  class << self 
    def mkdirLazy(dirPath)
      File.directory?(dirPath) or Dir.mkdir(dirPath)
    end
  end  
end

gameName = srcFolderPath.split(File::SEPARATOR).last
gameNameSplitMark = "_#{ gameName }"
# try to be smart. May be game files should be splitted and actual dir name is { gameNameSplitMark }. That for case if we overwrites files  to { destFolderPath }
tempGameName = File.directory?(File.join(destFolderPath, gameNameSplitMark)) && gameNameSplitMark or File.directory?(File.join(destFolderPath, gameName)) && gameName 
debug tempGameName
Dir.mkdirLazy(File.join(destFolderPath, tempGameName))

isSplit = no
fileNumberCopied = 0
totalFileNumber = 0
Dir.glob("#{ srcFolderPath }**/*").each { |fullSrcFilePath|
  relativeSrcFilePath = fullSrcFilePath.slice(srcFolderPath.size, fullSrcFilePath.size)
  fullDestFilePath = File.join(destFolderPath, tempGameName, relativeSrcFilePath)
  debug fullDestFilePath
  if(File.directory?(fullSrcFilePath))
    Dir.mkdirLazy(fullDestFilePath)
  else
    fileSize = File.size?(fullSrcFilePath)
    if(fileSize == nil)
      warning("Can not stat #{ fullSrcFilePath.toWindowsFilePathStyle() }. Skipping")
    elsif(maxFat32FileSize <= fileSize)
      isSplit = yes
      log("#{ fullSrcFilePath.toWindowsFilePathStyle() } -> #{ fullDestFilePath.toWindowsFilePathStyle() }.666xx #{ Filesize.new(fileSize).pretty() }")
      `split --bytes=#{ maxFat32FileSize } -d "#{ fullSrcFilePath }" "#{ fullDestFilePath }.666" 2> nul`
      fileNumberCopied += 1
    else
      log("#{ fullSrcFilePath.toWindowsFilePathStyle() } -> #{ fullDestFilePath.toWindowsFilePathStyle() } #{ Filesize.new(fileSize).pretty() }")
      `cp -u "#{ fullSrcFilePath.toWindowsFilePathStyle() }" "#{ fullDestFilePath.toWindowsFilePathStyle() }"`
      fileNumberCopied += 1
    end
    totalFileNumber += 1
  end  
}

debug isSplit

if(isSplit)
  File.rename(File.join(destFolderPath, tempGameName), File.join(destFolderPath, gameNameSplitMark))
else
  File.rename(File.join(destFolderPath, tempGameName), File.join(destFolderPath, gameName))
end

log("#{ fileNumberCopied } was copied from total #{ totalFileNumber }".with { |r| 
  if(fileNumberCopied == totalFileNumber)
    r.green
  else
    r.red
  end  
})

