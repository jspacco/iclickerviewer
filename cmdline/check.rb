require 'set'
require 'yaml'

clicker_ignore_file = 'cmdline/clicker_ignore.yml'
folder = 'KnoxCS142S17'

ignore_hash = YAML.load_file(clicker_ignore_file)
ignore = Set.new
if ignore_hash.has_key?(folder)
  ignore = Set.new(ignore_hash[folder])
end
puts "We will ignore these clicker IDs #{ignore}"
puts "#{ignore.length}"
ignore.each do |x|
  puts x
  puts x.class.name
end
puts ignore.include?('#4262CCEA')
