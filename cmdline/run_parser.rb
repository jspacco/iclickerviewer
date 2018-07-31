require_relative 'parse'
require_relative 'command_line'
require 'yaml'

if __FILE__ == $0
  root = '/Users/jspacco/projects/clickers/data/'

  # These either had a different vote count format, or clickers to be ignored

#  parse_course(root, 'UIC.CS361S18', 'CS361', 'UIC', 'spring', 2018, 'Taylor', false)
  parse_course(root, 'UIUC.CS233F17-1', 'CS233', 'UIUC', 'fall', 2017, 'Herman', false)
  parse_course(root, 'UIUC.CS233F17-2', 'CS233', 'UIUC', 'fall', 2017, 'Herman', false)

  # parse_course(root, 'UIC.CS111F17', 'CS111', 'UIC', 'fall', 2017, 'Taylor', false)
  # parse_course(root, 'UIC.CS111F17-law', 'CS111', 'UIC', 'fall', 2017, 'Taylor', false)
  # parse_course(root, 'UIC.CS111F16', 'CS111', 'UIC', 'fall', 2016, 'Green', false)
  # parse_course(root, 'UIC.CS362F17', 'CS362', 'UIC', 'fall', 2017, 'Taylor', false)

  # parse_course(root, 'KnoxCS141W16', 'CS141', 'Knox', 'winter', 2016, 'Dooley', false)
  # parse_course(root, 'KnoxCS141F16-2', 'CS141', 'Knox', 'fall', 2016, 'Dooley', false)

  # parse_course(root, 'KnoxCS142S17', 'CS142', 'Knox', 'spring', 2017, 'Bunde', false)
  #parse_course(root, 'UCSD.CSE141S17-1', 'CSE141', 'UCSD', 'spring', 2017, 'Porter', false)
  #parse_course(root, 'UCSD.CSE141S17-2', 'CSE141', 'UCSD', 'spring', 2017, 'Porter', false)


  # parse_course(root, 'UT.CSC108F16-L0101', 'CS108', 'Toronto', 'fall', 2016, 'Tong')
  # p "done with UT.CSC108F16-L0101"
  # parse_course(root, 'UT.CSC108F16-L0102', 'CS108', 'Toronto', 'fall', 2016, 'Petersen')
  # p "done with UT.CSC108F16-L0102"
  # parse_course(root, 'UT.CSC108F16-L0104', 'CS108', 'Toronto', 'fall', 2016, 'Dema')
  # p "done with UT.CSC108F16-L0104"
  #
  # parse_course(root, 'KnoxCS141F16-1', 'CS141', 'Knox', 'fall', 2016, 'Budach')
  # p "done with KnoxCS141F16-1"
  # parse_course(root, 'KnoxCS141W17-2', 'CS141', 'Knox', 'winter', 2017, 'Spacco')
  # p "done with KnoxCS141W17-2"
  #
  # parse_course(root, 'UIC.CS111S16', 'CS111', 'UIC', 'spring', 2016, 'Taylor')
  # p "done with UIC.CS111S16"
  #
  # parse_course(root, 'UIC.CS261S17', 'CS261', 'UIC', 'spring', 2017, 'Taylor')
  # p "done with UIC.CS261S17"
  #
  # parse_course(root, 'UIC.CS361F15', 'CS361', 'UIC', 'fall', 2015, 'Taylor')
  # p "done with UIC.CS361F15"
  # parse_course(root, 'UIC.CS361S16', 'CS361', 'UIC', 'spring', 2016, 'Taylor')
  # p "done with UIC.CS361S16"
  # parse_course(root, 'UIC.CS361F16', 'CS361', 'UIC', 'fall', 2016, 'Taylor')
  # p "done with UIC.CS361F16"
  # parse_course(root, 'UIC.CS361S17', 'CS361', 'UIC', 'spring', 2017, 'Taylor')
  # p "done with UIC.CS361S17"
  #
  # parse_course(root, 'UIC.CS362F16', 'CS362', 'UIC', 'fall', 2016, 'Taylor')
  # p "done with UIC.CS362F16"
  #
  # parse_course(root, 'UIC.CS385S16', 'CS385', 'UIC', 'spring', 2016, 'Taylor')
  # p "done with UIC.CS385S16"
  # parse_course(root, 'UIC.CS385F16', 'CS385', 'UIC', 'fall', 2016, 'Taylor')
  # p "done with UIC.CS385F16"
  #
  # parse_course(root, 'UIC.CS450F15', 'CS450', 'UIC', 'fall', 2015, 'Taylor')
  # p "done with UIC.CS450F15"
  # parse_course(root, 'UIC.CS450S17', 'CS450', 'UIC', 'spring', 2017, 'Taylor')
  # p "done with UIC.CS450S17"

  # parse_course(root, 'KnoxCS142W15', 'CS142', 'Knox', 'winter', 2015, 'Bunde', false)
  # p "done with KnoxCS142W15"
  # parse_course(root, 'KnoxCS142S15', 'CS142', 'Knox', 'spring', 2015, 'Bunde', false)
  # p "done with KnoxCS142S15"
  # parse_course(root, 'KnoxCS142W16', 'CS142', 'Knox', 'winter', 2016, 'Bunde', false)
  # p "done with KnoxCS142W16"
  # parse_course(root, 'KnoxCS142S16', 'CS142', 'Knox', 'spring', 2016, 'Bunde', false)
  # p "done with KnoxCS142S16"
  # parse_course(root, 'KnoxCS142W17', 'CS142', 'Knox', 'winter', 2017, 'Bunde', false)
  # p "done with KnoxCS142W17"
  # parse_course(root, 'KnoxCS142S17', 'CS142', 'Knox', 'spring', 2017, 'Bunde', false)
  # p "done with KnoxCS142S17"

  # parse_course(root, 'UCSD.CSE141F14-A', 'CSE141', 'UCSD', 'fall', 2014, 'Porter', false)
  # p "done with UCSD.CSE141F14-A"
  # parse_course(root, 'UCSD.CSE141F14-B', 'CSE141', 'UCSD', 'fall', 2014, 'Porter', false)
  # p "done with UCSD.CSE141F14-B"
  # parse_course(root, 'UCSD.CSE141F15', 'CSE141', 'UCSD', 'fall', 2015, 'Porter', false)
  # p "done with UCSD.CSE141F15"
  # parse_course(root, 'UCSD.CSE141F16', 'CSE141', 'UCSD', 'fall', 2016, 'Porter', false)
  # p "done with UCSD.CSE141F16"
  # parse_course(root, 'UCSD.CSE141S17-1', 'CSE141', 'UCSD', 'spring', 2017, 'Porter', false)
  # p "done with UCSD.CSE141S17-1"
  # parse_course(root, 'UCSD.CSE141S17-2', 'CSE141', 'UCSD', 'spring', 2017, 'Porter', false)
  # p "done with UCSD.CSE141S17-2"

  # parse_course(root, 'KnoxCS226F14', 'CS226', 'Knox', 'fall', 2014, 'Bunde', false)
  # p "done with KnoxCS226F14"
  # parse_course(root, 'KnoxCS226F15', 'CS226', 'Knox', 'fall', 2015, 'Bunde', false)
  # p "done with KnoxCS226F15"
  # parse_course(root, 'KnoxCS214F16', 'CS214', 'Knox', 'fall', 2016, 'Bunde', false)
  # p "done with KnoxCS214F16"
  #
  # parse_course(root, 'KnoxCS180S16', 'CS180K', 'Knox', 'spring', 2016, 'Bunde', false)
  # p "done with KnoxCS180S16"
  #
  # parse_course(root, 'KnoxCS208W17', 'CS208', 'Knox', 'winter', 2017, 'Bunde', false)
  # p "done with KnoxCS208W17"
  #
  # parse_course(root, 'KnoxCS309F14', 'CS309', 'Knox', 'fall', 2014, 'Bunde', false)
  # p "done with KnoxCS309F14"

  # parse_course(root, 'KnoxCS309W16', 'CS309', 'Knox', 'winter', 2016, 'Bunde', false)
  # p "done with KnoxCS309W16"




end
