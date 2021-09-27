linksFilePath = ARGV[0]
outDir = ARGV[1]
open(linksFilePath) { |linksFile|
  i = Dir.glob(outDir + "*.mp4").map { |filePath| File.basename(filePath).to_i }.compact().max + 1 
  linksFile.each_line { |url|
    `wget -O "#{ outDir }#{  sprintf('%03d', i) }.mp4" "#{ url }"`
    i = i + 1
  }
}