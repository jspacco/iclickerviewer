course_hash = new.env()

course_hash[["1"]] = "UT.CSC108F16-L0101"
course_hash[["2"]] = "UT.CSC108F16-L0102"
course_hash[["3"]] = "UT.CSC108F16-L0104"
course_hash[["4"]] = "KnoxCS141F16-1"
course_hash[["5"]] = "KnoxCS141W17-2"
course_hash[["6"]] = "UIC.CS111S16"
course_hash[["7"]] = "UIC.CS261S17"
course_hash[["8"]] = "UIC.CS361F15"
course_hash[["9"]] = "UIC.CS361S16"
course_hash[["10"]] = "UIC.CS361F16"
course_hash[["11"]] = "UIC.CS361S17"
course_hash[["12"]] = "UIC.CS362F16"
course_hash[["13"]] = "UIC.CS385S16"
course_hash[["14"]] = "UIC.CS385F15"
course_hash[["15"]] = "UIC.CS450F15"
course_hash[["16"]] = "UIC.CS450S17"
course_hash[["17"]] = "KnoxCS142W15"
course_hash[["18"]] = "KnoxCS142S15"
course_hash[["19"]] = "KnoxCS142W16"
course_hash[["20"]] = "KnoxCS142S16"
course_hash[["21"]] = "KnoxCS142W17"
course_hash[["22"]] = "KnoxCS142S17"
course_hash[["23"]] = "UCSD.CSE141F14-A"
course_hash[["24"]] = "UCSD.CSE141F14-B"
course_hash[["25"]] = "UCSD.CSE141F15"
course_hash[["26"]] = "UCSD.CSE141F16"
course_hash[["27"]] = "UCSD.CSE141S17-1"
course_hash[["28"]] = "UCSD.CSE141S17-2"

getcourse = function(num) {
  return(course_hash[[toString(num)]])
}
