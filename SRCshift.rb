#!/usr/bin/env ruby

# SRCshift.rb - convert Steins;Gate Android (english translation) SRC scripts
# by carstene1ns, 2015
# under MIT license

# wether to show the lookup table?
SHOW_TABLE = 0

# helper
def error_out(msg)
  puts "ERROR: #{msg}"
  exit 1
end

# no args?
if ARGV.size != 1
  puts "Usage: #{__FILE__} file.SCR"
  exit 0
end

# no file?
file = ARGV[0]
if not File.file?(file)
  error_out "#{file} is not a file!"
end

# generate a lookup table
lt = Hash.new(256)
alternate = -4
base = 160
(0..255).each do |i|
  # toggle +4 / -4
  alternate *= -1 if i.modulo(4).zero?
  # shift
  base -= 64 if i.modulo(32).zero?
  # assign
  lt[i] = base + i + alternate & 0xff
end

# show table
if SHOW_TABLE == 1
  puts "Character replacements:"
  lt.each do |k, v|
    next if not k.modulo(8).zero?
    (0..7).each do |i|
      print "%02x => %02x  " % [k + i, lt[k + 1]]
    end
    puts
  end
end

# replace!
print "Now converting..."
src = IO.read(file)
chars = src.unpack('C*')
chars.map!{ |c| lt[c] }
src = chars.pack('C*')
File.open(file, 'w') { |f| f.write src }
puts "done!"

# cleanup
exit 0

# EOF
