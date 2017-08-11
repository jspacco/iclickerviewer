source('utils.r')
library(data.table)
library(Cairo)
library(ggplot2)
library(xtable)
# require(plyr)

outdir = '/Users/jspacco/projects/clickers/sigcse2018'
mydir = function(path) {
  return(paste(outdir, '/', path, sep=''))
}

"---
TODO list from Overlead:
#  Scatterplot of question correctness on first ask, vs after discussion
#  Number of questions per class
#  Number of single question, threshhold for single questions
#  Non-MCQ? How are they used? Quizes, surveys, timers
#  Multiple answer correct?
#  Breakdown of question difficulty
#  Characteristics of questions that students do worse after discussion
#  are questions easier in CS 1?
#  Do faculty add more questions over time?
#  Content-slides vs question-slides: ITiCSE, hire an undergrad
#  Time per question

TODO
* lookups for class names for table creation (anonymous and real,
  probably swap the functions)
* anonymize instructors same way

---"

filename = 'courses.csv'
ses = read.csv(filename)

#
# Compute "normalized gain", which is the fraction of possible improvement
# that we achieved.
#


# number of class periods per course
num_classes = setNames(
  aggregate(class_id ~ course_id,
  data = unique(ses[,c('course_id','class_id')]),
  FUN = length), c("course_id", "num_classes"))

# average number of questions per class period
# uses the number of questions per class periods per course
avg_cqs = setNames(aggregate(qid ~ course_id,
  data = aggregate(qid ~ course_id * class_id, data = ses, FUN = length),
  FUN = mean), c('course_id', 'av_cqs'))

# total number of clicker questions per course
num_cqs = setNames(
  aggregate(qid ~ course_id, data = ses, FUN = length),
  c('course_id', 'num_cqs'))

#
# course, num class periods, num CQs, avg CQs
# FIXME rename column and row headers
#
# merge 3 frames together
table1 = merge(merge(num_classes, num_cqs, by=c('course_id')),
  avg_cqs, by=c('course_id'))
# generate xtable
tab1 = xtable(table1,
  align = "ccccr",
  latex.environments="center",
  digits = c(0, 0, 0, 0, 1),
  format.args = list(format = c("d","d","d","f")))
# send output to file using print, an amazing function
print(tab1, file=mydir('charts/table1.tex'), include.rownames=FALSE)


# get only the UIC courses (which have been tagged)
uicses = ses[grep("UIC", ses$course_name),]




#
# TODO
# Table: How are we using the clickers?
# course, total votes, paired votes, single votes, other clicker usage
#

#
# TODO timing
# how long for single votes?
# how long for 1st and 2nd votes?
# difficulty vs time?
# difficulty vs course level (i.e. cs-1, architecture, etc)
#

#
# TODO plot CQ movements
#

#
# TODO normalized gain
# questions with space for improvement that don't improve
# questions with space for improvement that DO improve
# fraction of easy, medium, and hard questions
#


# OK, R is a terrible language and using "+" to populate a scatterplot with points
#   is not intuitive syntax, to say the least.
go = function() {

ggplot(subset(ses, question_type == 3 & num_correct_answers == 1),
  aes(pct1st_correct, pct2nd_correct)) +
  geom_point(aes(color = course_name), alpha = 0.1) +
  scale_y_reverse( lim=c(1.0,0.0))
}

go()
