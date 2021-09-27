#!/usr/bin/env ruby
# [https://github.com/xunker/svg_tiler/blob/master/tiler.rb]

svg = File.open(ARGV[0]).read

svg_header = svg.slice(0, svg.index('</desc>')+8)
svg.sub!(svg_header, '')
svg_footer = '</svg>'

svg = svg.sub!(/#{svg_footer}$/, '')

start_x = -40000
start_y = -30000

end_x = 40000
end_y = 30000

x_step = 20000
y_step = 35000

current_x = start_x
current_y = start_y

File.open(ARGV[1], 'w') do |output|
  output.puts svg_header
  # output.puts '<g transform="translate(13000,21000)">'

  while current_y <= end_y do
    while current_x <= end_x do
      puts "current_x: #{current_x}, current_y: #{current_y}"
      output.puts "<g transform=\"translate(#{current_x},#{current_y})\">"
      output.puts svg
      output.puts '</g>'
      current_x += x_step
    end
    current_x = start_x
    current_y += y_step
  end

  output.puts svg_footer
end
