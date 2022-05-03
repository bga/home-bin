#!/usr/bin/env ruby
port = ARGV[0]
loop {
  activePorts = `netstat -a`
  if(activePorts.match(":#{ port }"))
    break
  end
  sleep 3
}

