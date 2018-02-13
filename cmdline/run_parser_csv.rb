require_relative 'parse_csv'
#require_relative 'command_line'
#require 'yaml'

if __FILE__ == $0
  puts ENV['DATABASE_URL'].class
  puts "Faloopie"
  root = '/Users/jspacco/projects/clickers/data/'

  # These either had a different vote count format, or clickers to be ignored
  # parse_course(root, 'KnoxCS142S17', 'CS142', 'Knox', 'spring', 2017, 'Bunde', false)
  #parse_course(root, 'UCSD.CSE141S17-1', 'CSE141', 'UCSD', 'spring', 2017, 'Porter', false)
  #parse_course(root, 'UCSD.CSE141S17-2', 'CSE141', 'UCSD', 'spring', 2017, 'Porter', false)
  parse_course(root,'KnoxCS141F15-1', 'CS141', 'Knox', 'fall', 2015, 'Spacco', false)
  parse_course(root,'KnoxCS141F15-2', 'CS141', 'Knox', 'fall', 2015, 'Spacco', false)
  parse_course(root,'KnoxCS141W15', 'CS141', 'Knox', 'winter', 2015, 'Spacco', false)
  parse_course(root, 'KnoxCS201S15', 'CS201', 'Knox', 'spring', 2015, 'Spacco', false)
  parse_course(root, 'KnoxCS201S16', 'CS201', 'Knox', 'spring', 2016, 'Spacco', false)
end
