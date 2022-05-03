#!/usr/bin/env ruby
require "date"
def my(*args)
end
my null = nil
my specTest = ENV["specTest"] != null
# my specTest = true
my address = "8.8.8.8"
my timeDiffFormat = "%H:%M:%S"
my lastConnectionChangeDate = Time.now()
my log = lambda { |*args|
  $stdout.puts(*args)
  open("r://macroPing.log", "a+") { |f|
    f.puts(*args)
    f.close()
  }
} 

class Time
  def zero
    Time.new(0, 1, 1, 0, 0, 0)
  end
end

my onConnectionChange = lambda { |connection|
  my now = Time.now()
  if(connection == null)
    log.call("disconnected\t#{ now } - #{ lastConnectionChangeDate } = #{ (Time.new().zero + (now - lastConnectionChangeDate)).strftime(timeDiffFormat) }")
  else
    log.call("connected\t#{ now } - #{ lastConnectionChangeDate } = #{ (Time.new().zero + (now - lastConnectionChangeDate)).strftime(timeDiffFormat) }")
  end
  lastConnectionChangeDate = now
}
my connection = null
if(specTest)
  # onConnectionChange.call({  })
  onConnectionChange.call(null)
end
IO.popen("ping -t #{ address }").each_line { |line|
  
  if(null)
  
  elsif(line.match(/[ ]+ timed [ ]+ out\./x) != null)
  elsif(line.match(/[ ]+ time \=/x) != null)
    if(connection == null)
      connection = {  }
      onConnectionChange.call(connection)
    else
    end
  elsif(line.match(/[ ]+ Destination [ ]+ net [ ]+ unreachable\./x) != null)
    if(connection != null)
      connection = null
      onConnectionChange.call(connection)
    else
    end
  end
}