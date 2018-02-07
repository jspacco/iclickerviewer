require_relative 'parse_csv_d'
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
  parse_course(root,'UT.CSC108F14-L0101', 'CS108', 'UT', 'fall', 2014, 'Dan', false)
end
