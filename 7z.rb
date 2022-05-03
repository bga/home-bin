#!/usr/bin/env ruby
# 7z {-p%%P} -r0 -y x %%A @%%LQMN
# corrects extracting 

null = nil
yes = true
no = false
def log(*args)
  p *args
end

log "ruby!"
class String
  def subRange(b, e = self.size)
    def correctPos(x, shift)
      if(x < 0)
        x = self.size + x
      end
      [[x, self.size - 1 + shift].min, 0].max
    end
    b = correctPos(b, 1)
    e = correctPos(e, 1)
    if(b > e)
      ""
    else
      self.slice(b, e - b)
    end
  end
end
class Array
  def subRange(b, e = self.size)
    def correctPos(x, shift)
      if(x < 0)
        x = self.size + x
      end
      [[x, self.size - 1 + shift].min, 0].max
    end
    b = correctPos(b, 1)
    e = correctPos(e, 1)
    if(b > e)
      []
    else
      self.slice(b, e - b) || []
    end
  end
end

run7z = proc { |options|
  # p ["D:\7-zip\7z.exe"].concat(options)
  # `#{  }`
  pid = spawn(*(["7z.bat"].concat(options)), 
    {
      # :in => :in, 
      # :out => :out, 
      # :err => :err 
    }
  )
  log pid
  Process.wait(pid)
}

args = ARGV[0 ... ARGV.size]
commandIndex = args.find_index {
  |v|
  v.match(/^-/) == null
}
proc {
  allMask = "*"
  class String
    define_method(:pathParts) {
      ret = self.split(/[\\\/]/, -1)
      ret
    }
  end
}.call
if(commandIndex != null && args[commandIndex] == "x" && args.find_index("--trim-common-path") != null)
  args.delete_at(args.find_index("--trim-common-path"))
  listFileName = args.last
  log listFileName
  archiveFilePaths = open(listFileName[1 .. listFileName.size], "rt").read()
    .split("\n")
    .map {
      |v|
      if(v[0] == "\"")
        v.subRange(1, -1)
      else
        v
      end  
    }
  log archiveFilePaths
  # log archiveFilePaths[0].pathParts
  # log archiveFilePaths[1].pathParts
  # log archiveFilePaths[2].pathParts
  archiveCommonPath = begin
    r = ""
    i = 0
    loop {
      if((archiveFilePaths
        .map {
          |archiveFilePath|
          # without file
          archiveFilePath.pathParts.size 
        }.min) == i
      )
        r = archiveFilePaths[0].pathParts.subRange(0, i - 1).join("/")
        break
      end
      if((archiveFilePaths
        .map {
          |archiveFilePath|
          archiveFilePath.pathParts[i]
        }.uniq()).size != 1
      )
        r = archiveFilePaths[0].pathParts.subRange(0, i).join("/")
        break
      end
      
      i = i + 1
    }
    log i
    r
  end
  outputDir = begin
    r = args.select {
      |arg|
      arg.match(/^-o/) != null
    }[0]
    if(r != null)
      r.subRange(2)
    else
      Dir.pwd + "/"
    end  
  end
  log ["archiveCommonPath", archiveCommonPath]
  run7z.call(args)
  if(archiveCommonPath != "")
    pathJoin = proc { |*args|
      require "Pathname"
      r = Pathname.new("")
      (0 ... args.size).each { |i|
        if(args[i] != null)
          r = r + args[i]
        end
      }
      r.to_s()
    }
    
    tempDirName = begin
      i = 0
      r = ""
      loop {
        if(Dir.entries(pathJoin.call(Dir.pwd, outputDir, archiveCommonPath)).find_index(i.to_s(36)) == null && 
          Dir.entries(pathJoin.call(Dir.pwd, outputDir)).find_index(i.to_s(36)) == null
        )
          r = i.to_s(36)
          break
        end
        i = i + 1
      }
      r
    end
    require "fileutils"
    # fu = FileUtils::DryRun
    fu = FileUtils
    fu.move(pathJoin.call(Dir.pwd, outputDir, archiveCommonPath.pathParts[0]), pathJoin.call(Dir.pwd, outputDir, tempDirName))
    log archiveCommonPath.pathParts.subRange(1)
    log pathJoin.call(Dir.pwd, outputDir, tempDirName, archiveCommonPath.pathParts.subRange(1).join("/"), "*")
    log Dir.glob(pathJoin.call(Dir.pwd, outputDir, tempDirName, archiveCommonPath.pathParts.subRange(1).join("/"), "*"))
    fu.move(Dir.glob(pathJoin.call(Dir.pwd, outputDir, tempDirName, archiveCommonPath.pathParts.subRange(1).join("/"), "*")) , pathJoin.call(Dir.pwd, outputDir), { :force => yes })
    fu.rm_rf(pathJoin.call(Dir.pwd, outputDir, tempDirName))
  end  
else 
  run7z.call(args)
end
