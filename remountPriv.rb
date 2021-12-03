newPrivDriveLetter = nil
oldPrivDriveLetter = nil
if(ARGV.size == 2)
	oldPrivDriveLetter = ARGV[0].gsub("\\", "/").upcase().chomp("/") + "/"
	newPrivDriveLetter = ARGV[1].gsub("\\", "/").upcase.chomp("/") + "/"
else
	newPrivDriveLetter = ARGV[0].gsub("\\", "/").upcase.chomp("/") + "/"
end

# require "FileUtils"

debug = nil

operaPrivSymlink = "C:/Users/admin/AppData/Roaming/Opera/Opera/priv"
thunderbirdProfilesIniPath = "C:/Users/admin/AppData/Roaming/Thunderbird/profiles.ini"
taskBarPasswordLnkPath = "C:/Users/admin/AppData/Roaming/Microsoft/Internet Explorer/Quick Launch/User Pinned/TaskBar/Password Safe.lnk"
passwordSafePwsafeCfgPath = "C:/Users/admin/AppData/Local/PasswordSafe/pwsafe.cfg"

if(debug)
	operaPrivSymlink = "C:/Users/admin/AppData/Local/Temp/xx/priv"
	thunderbirdProfilesIniPath = "R:/profiles.ini"
	taskBarPasswordLnkPath = "R:/Password.lnk"
	passwordSafePwsafeCfgPath = "R:/pwsafe.cfg"
end

class String
	def toUnixSlashes()
		self.gsub("\\", "/")
	end
	def toWindowsSlashes()
		self.gsub("/", "\\")
	end
	def subStringI(what, to)
		self.sub(Regexp.new(Regexp.quote(what), Regexp::IGNORECASE)) { to }
	end
	def gsubStringI(what, to)
		self.gsub(Regexp.new(Regexp.quote(what), Regexp::IGNORECASE)) { to }
	end
	def toUtf16LE
		self.chars.map { |char| "#{ char }\x00" }.join("")
	end
end

require 'open3'

class << File
  alias_method :old_symlink, :symlink
  alias_method :old_symlink?, :symlink?

  def symlink(old_name, new_name)
    #if on windows, call mklink, else self.symlink
    if RUBY_PLATFORM =~ /mswin32|cygwin|mingw|bccwin/
      #windows mklink syntax is reverse of unix ln -s
      #windows mklink is built into cmd.exe
      #vulnerable to command injection, but okay because this is a hack to make a cli tool work.
      dirOption = File.directory?(old_name) ? "/J" : ""
      puts old_name
      puts new_name
      puts dirOption
      stdin, stdout, stderr, wait_thr = Open3.popen3('cmd.exe', "/c", "mklink", dirOption, new_name.toWindowsSlashes(), old_name.toWindowsSlashes())
      wait_thr.value.exitstatus
    else
      self.old_symlink(old_name, new_name)
    end
  end

  def symlink?(file_name)
    #if on windows, call mklink, else self.symlink
    if RUBY_PLATFORM =~ /mswin32|cygwin|mingw|bccwin/
      #vulnerable to command injection because calling with cmd.exe with /c?
      stdin, stdout, stderr, wait_thr = Open3.popen3("cmd.exe /c dir #{file_name} | find \"SYMLINK\"")
      wait_thr.value.exitstatus
    else
      self.old_symlink?(file_name)
    end
  end
end

# puts "xXyYxZ".gsubStringI("x", "w")

def File_readlink(path)
	File.readlink(path).split("\x00")[0]
end
def File_symlinkDir(fromPath, toPath)
	`mklink /J #{ fromPath.toWindowsSlashes() } #{ toPath.toWindowsSlashes() }`
end

oldPrivPath = nil
if(oldPrivDriveLetter == nil)
  oldPrivPath = File_readlink(operaPrivSymlink)
  puts oldPrivPath
  oldPrivDriveLetter = oldPrivPath.match(/^\w\:\//)[0]
else
  oldPrivPath = "#{ oldPrivDriveLetter }\\opera"
end

puts "Remounting #{ oldPrivDriveLetter.toWindowsSlashes() } -> #{ newPrivDriveLetter.toWindowsSlashes() }"

File.unlink(operaPrivSymlink)
File.symlink(oldPrivPath.sub(oldPrivDriveLetter, newPrivDriveLetter.toUnixSlashes()), operaPrivSymlink)
# FileUtils.ln_s(operaPrivSymlink, operaPrivSymlink.sub(oldPrivDriveLetter, newPrivDriveLetter.toUnixSlashes()))
# File_symlinkDir(operaPrivSymlink, operaPrivSymlink.sub(oldPrivDriveLetter, newPrivDriveLetter.toUnixSlashes()))

def transformFileData(filePath, openMode = "t", pairs = [], &b)
	open(filePath, "r+#{ openMode }") { |f|
		origT = t = f.read()
		
		if(b)
			t = b.call(t)
		end
		pairs.each { |f|
			t = f.call(t)
		}
		if(t != origT)
			f.rewind()
			f.write(t)
		end
		f.close()
	}
end

def Process_killByName(name)
  r, w = IO.pipe
  Process.wait(Process.spawn("taskkill /im #{ name } /f", [:out, :err] => w))
end

Process_killByName("pwsafe.exe")

if(File.exist?(taskBarPasswordLnkPath))
	taskBarPasswordLnkRenamedPath = "#{ taskBarPasswordLnkPath }.tmp"
	File.rename(taskBarPasswordLnkPath, taskBarPasswordLnkRenamedPath)
	transformFileData(taskBarPasswordLnkRenamedPath, "b") { |t|
		t.gsubStringI(oldPrivDriveLetter.toWindowsSlashes().toUtf16LE(), newPrivDriveLetter.toWindowsSlashes().toUtf16LE())
	}
	File.rename(taskBarPasswordLnkRenamedPath, taskBarPasswordLnkPath)
end

if(File.exist?(passwordSafePwsafeCfgPath))
	transformFileData(passwordSafePwsafeCfgPath) { |t|
		t.gsubStringI(oldPrivDriveLetter.toWindowsSlashes(), newPrivDriveLetter.toWindowsSlashes())
	}
end

if(File.exist?(thunderbirdProfilesIniPath))
	transformFileData(thunderbirdProfilesIniPath) { |t|
		t.gsubStringI(oldPrivDriveLetter.toWindowsSlashes(), newPrivDriveLetter.toWindowsSlashes())
	}
end

exit(1)
puts oldPrivPath.subStringI(oldPrivDriveLetter, newPrivDriveLetter.toUnixSlashes())
