#!/usr/bin/env ruby
urlOfLocalFilePath = ARGV[0]
if(urlOfLocalFilePath.match(/^http(s)?\:/) == nil) 
  localFilePath = urlOfLocalFilePath
  `mpc #{ localFilePath }`
else
  tempFilePath = "r:/a.mp4"
  class String
    def toWinPath
      self.gsub("/", "\\")
    end
  end
  url = urlOfLocalFilePath
  wgetPid = Process.spawn("wget -O #{ tempFilePath.toWinPath() } \"#{ url }\"")
  Thread.new {
    Process.waitpid(wgetPid)
    wgetPid = nil
    puts("wgetPid end")
  }
  loop {
    if(File.exists?(tempFilePath))
      break
    else
      sleep(0.010)
    end
  }
  terminate = lambda { ||
    puts("INT")
    # Process.kill(0, wgetPid)
    # Process.kill("INT", wgetPid)
    if(wgetPid != nil)
      `taskkill /F /T /PID #{ wgetPid }`
    else
    end
    loop {
      if(File.exists?(tempFilePath) == false)
        break
      else
        `del #{ tempFilePath.toWinPath() }`
      end  
    }
    exit
  }
  Signal.trap("INT") { 
    terminate.call()
  }
  Process.waitpid(Process.spawn("mpc #{ tempFilePath.toWinPath() }"))
  terminate.call()
end