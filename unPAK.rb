#!/usr/bin/env ruby

# unPAK.rb - extract Steins;Gate [Linear Bounded Phenogram] iOS PAK files
# by carstene1ns, 2015
# under MIT License

MAGIC = "filemark"
OFFSET_ENTRIES = 56
OFFSET_FILES = OFFSET_ENTRIES + 8
ENSTRY_SIZE = 64
FILEMAGIC = 'A32A16A16'

# helper
def error_out(msg)
  puts "ERROR: #{msg}"
  exit 1
end

# no args?
if ARGV.size != 1
  puts "Usage: #{__FILE__} file.PAK"
  exit 0
end

# no file?
input = ARGV[0]
if not File.file?(input)
  error_out "#{input} is not a file!"
end

# wrong type?
archive = open(input, 'rb')
if archive.read(8) != MAGIC
  error_out "#{input} is not a PAK file!"
end

# get entries
archive.seek(OFFSET_ENTRIES)
entries = archive.read(8).to_i
puts "Found %d files:" % entries

archive.seek(OFFSET_FILES)
puts "%-32s | %-16s | %-16s" % ["NAME", "OFFSET", "SIZE"]
puts "-" * 70
files = Array.new(entries)
for entry in 0..entries-1
  # read
  name, offset, size = archive.read(ENSTRY_SIZE).unpack(FILEMAGIC)
  # output
  puts "%32s | %16s | %16s" % [name, offset, size]
  # save
  files[entry] = { :name => name, :offset => offset.to_i, :size => size.to_i }
end
puts "-" * 70

OFFSET_DATA = OFFSET_FILES + entries * ENSTRY_SIZE

# extract
puts "\nNow extracting..."
md = entries.to_s.size
files.each_with_index { |file , index|
  # progress
  print "\r%#{md}d/%#{md}d %3d%%" % [ index, entries, index*100/entries ]
  $stdout.flush

  # write out
  archive.seek(OFFSET_DATA + file[:offset])
  output = open(file[:name], 'wb')
  output.write(archive.read(file[:size]))
  output.close
}
puts "\r=== All done! ==="

# cleanup
archive.close
exit 0

# EOF
