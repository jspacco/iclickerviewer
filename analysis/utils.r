library(xtable)

course_hash = new.env()

# key of the map have to be strings
course_hash[['1']] = 'UT.CSC108F16-L0101'
course_hash[['2']] = 'UT.CSC108F16-L0102'
course_hash[['3']] = 'UT.CSC108F16-L0104'
course_hash[['4']] = 'KnoxCS141F16-1'
course_hash[['5']] = 'KnoxCS141W17-2'
course_hash[['6']] = 'UIC.CS111S16'
course_hash[['7']] = 'UIC.CS261S17'
course_hash[['8']] = 'UIC.CS361F15'
course_hash[['9']] = 'UIC.CS361S16'
course_hash[['10']] = 'UIC.CS361F16'
course_hash[['11']] = 'UIC.CS361S17'
course_hash[['12']] = 'UIC.CS362F16'
course_hash[['13']] = 'UIC.CS385S16'
course_hash[['14']] = 'UIC.CS385F15'
course_hash[['15']] = 'UIC.CS450F15'
course_hash[['16']] = 'UIC.CS450S17'
course_hash[['17']] = 'KnoxCS142W15'
course_hash[['18']] = 'KnoxCS142S15'
course_hash[['19']] = 'KnoxCS142W16'
course_hash[['20']] = 'KnoxCS142S16'
course_hash[['21']] = 'KnoxCS142W17'
course_hash[['22']] = 'KnoxCS142S17'
course_hash[['23']] = 'UCSD.CSE141F14-A'
course_hash[['24']] = 'UCSD.CSE141F14-B'
course_hash[['25']] = 'UCSD.CSE141F15'
course_hash[['26']] = 'UCSD.CSE141F16'
course_hash[['27']] = 'UCSD.CSE141S17-1'
course_hash[['28']] = 'UCSD.CSE141S17-2'

getcourse = function(num) {
  # print(paste('num is ', num))
  # print(paste('type is ', typeof(num)))
  # print(paste('as.character is ', as.character(num)))
  key = as.character(num)
  # print(paste('key type is ', typeof(key)))
  # print(paste('key value is ', key))
  # return(course_hash[['toString(num)']])
  return(course_hash[[key]])
  # return(course_hash[['num']])
}

# XXX sink doesn't seem to work this way for some reason
xtableToFile = function(tab, filename) {
  ff = file(filename)
  sink(ff, type='output')
  # xtable(tab)
  tab
  sink()
  close(ff)
}

# XXX using xtable package instead
make_basic_table = function() {
  table = '
\\begin{table*}
\\centering
\\begin{tabular}{| l | l | l | l |}
\\hline
course & num. class periods & num clicker questions & avg. CQs / class \\\\
'

  paste(table, '
\\end{tabular}
\\caption{TODO: caption goes here}
\\label{tab:basic_stats}
\\end{table*}
')
  return(table)
}
