require_relative 'parse_csv'
#require_relative 'command_line'
#require 'yaml'

if __FILE__ == $0
  puts ENV['DATABASE_URL'].class
  puts "Faloopie"
  root = '/Users/errolkaylor/Desktop/Senior_Year/Research_Honors/'

  # These either had a different vote count format, or clickers to be ignored
  # parse_course(root, 'KnoxCS142S17', 'CS142', 'Knox', 'spring', 2017, 'Bunde', false)
  #parse_course(root, 'UCSD.CSE141S17-1', 'CSE141', 'UCSD', 'spring', 2017, 'Porter', false)
  #parse_course(root, 'UCSD.CSE141S17-2', 'CSE141', 'UCSD', 'spring', 2017, 'Porter', false)
  parse_course(root,'KnoxCS141F15-1', 'CS141', 'Knox', 'fall', 2015, 'Spacco', false)
end
