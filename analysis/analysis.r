source('utils.r')
library(data.table)
library(Cairo)
library(ggplot2)
library(xtable)
require(plyr)

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

question_types are
0: unknown
1: quiz
2: single
3: paired
4: non-MCQ
5: error

---"

filename = 'courses.csv'
ses = read.csv(filename)


# number of class periods per course
num_classes = setNames(
  aggregate(class_id ~ course_id,
  data = unique(ses[,c('course_id','class_id')]),
  FUN = length), c("course_id", "num_classes"))

# average number of questions per class period
# uses the number of questions per class periods per course
avg_cqs = setNames(aggregate(qid ~ course_id,
  data = aggregate(qid ~ course_id * class_id, data = ses, FUN = length),
  FUN = mean), c('course_id', 'avg_cqs'))

# total number of clicker questions per course
num_cqs = setNames(
  aggregate(qid ~ course_id, data = ses, FUN = length),
  c('course_id', 'num_cqs'))

#
# Table #1
# chats/table1.text
#
# XXX Basic stats: course, num class periods, num CQs, avg CQs
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
  format.args = list(format = c('d','d','d','f')),
  caption = "For each class, the number of class periods,
the total number of clicker quesions,
and the average number of clicker questions per class period.",
  label = "tab:basic-class-stats"
  )
# send output to file using print, an amazing function
print(tab1, file=mydir('charts/table1.tex'),
  include.rownames=FALSE)


#
# Table #2
# charts/table2.tex
#
# XXX Table: How are we using the clickers?
# course, paired, single, quiz, nonmcq, paired>1correct, single>1correct
#
# num paired questions per course
num_paired = setNames(aggregate(qid ~ course_id,
  data = subset(ses, question_type == 3 & num_correct_answers == 1),
  FUN = length), c('course_id', 'num_paired'))
# num single questions per course
num_single = setNames(aggregate(qid ~ course_id,
  data = subset(ses, question_type == 2 & num_correct_answers == 1),
  FUN = length), c('course_id', 'num_single'))
# num quiz questions per course
num_quiz = setNames(aggregate(qid ~ course_id,
  data = subset(ses, question_type == 1 & num_correct_answers == 1),
  FUN = length), c('course_id', 'num_quiz'))
# num non-MCQ
num_nonmcq = setNames(aggregate(qid ~ course_id,
  data = subset(ses, question_type == 4),
  FUN = length), c('course_id', 'num_nonmcq'))
# num paired questions, > 1 correct answer
num_paired_gt1c = setNames(aggregate(qid ~ course_id,
  data = subset(ses, question_type == 3 & num_correct_answers > 1),
  FUN = length), c('course_id', 'num_paired_gt1c'))
# num single questions, > 1 correct answer
num_single_gt1c = setNames(aggregate(qid ~ course_id,
  data = subset(ses, question_type == 2 & num_correct_answers > 1),
  FUN = length), c('course_id', 'num_single_gt1c'))
table2 = join_all(list(num_paired, num_single, num_quiz,
  num_nonmcq, num_paired_gt1c, num_single_gt1c),
  by = 'course_id',
  type = 'full')

# course, paired, single, quiz, nonmcq, paired>1correct, single>1correct
tab2 = xtable(table2,
  align = "cccccccc",
  latex.environments="center",
  digits = c(0, 0, 0, 0, 0, 0, 0, 0),
  format.args = list(format = c('d','d','d','d','d','d','d')),
  caption = "How are each faculty using the clickers?
For each class, the number of paired and single clicker questions with one answer,
the number of times the clickers were used for in-class quizzes,
the number of uses of the clicker for an in-class exercise that was not
multiple choice (such as using the clickers as a timer for an ungraded
in-class exercise, or a 'confidence vote'), and the number of paired and
single clicer questions with more than one correct answer.",
  label = "tab:basic-question-stats"
)
# send output to file using print, an amazing function
print(tab2,
  file=mydir('charts/table2.tex'),
  include.rownames=FALSE,
  type = 'latex',
  floating = 'TRUE',
  floating.environment = "table*")

#
# TODO simple timing
# how long for single votes?
# how long for 1st and 2nd votes?
# how long for quiz votes, nonmcq, and >1correct answer?
avg_paired = setNames(aggregate(num_seconds ~ course_id,
  data = subset(ses, question_type == 3 & num_correct_answers == 1),
  FUN = mean), c('course_id', 'avg_paired'))
# num single questions per course
avg_single = setNames(aggregate(num_seconds ~ course_id,
  data = subset(ses, question_type == 2 & num_correct_answers == 1),
  FUN = mean), c('course_id', 'avg_single'))
# num quiz questions per course
avg_quiz = setNames(aggregate(num_seconds ~ course_id,
  data = subset(ses, question_type == 1 & num_correct_answers == 1),
  FUN = mean), c('course_id', 'avg_quiz'))
# num non-MCQ
avg_nonmcq = setNames(aggregate(num_seconds ~ course_id,
  data = subset(ses, question_type == 4),
  FUN = mean), c('course_id', 'avg_nonmcq'))
# num paired questions, > 1 correct answer
avg_paired_gt1c = setNames(aggregate(num_seconds ~ course_id,
  data = subset(ses, question_type == 3 & num_correct_answers > 1),
  FUN = mean), c('course_id', 'avg_paired_gt1c'))
# num single questions, > 1 correct answer
avg_single_gt1c = setNames(aggregate(num_seconds ~ course_id,
  data = subset(ses, question_type == 2 & num_correct_answers > 1),
  FUN = mean), c('course_id', 'avg_single_gt1c'))
table3 = join_all(list(avg_paired, avg_single, avg_quiz,
  avg_nonmcq, avg_paired_gt1c, avg_single_gt1c),
  by = 'course_id',
  type = 'full')

tab3 = xtable(table3,
  align = "cccccccc",
  latex.environments="center",
  digits = c(0, 0, 1, 1, 1, 1, 1, 1),
  format.args = list(format = c('d','d','d','d','d','d','d')))
# send output to file using print, an amazing function
print(tab3, file=mydir('charts/table3.tex'),
  include.rownames=FALSE,
  type = 'latex',
  floating = 'TRUE',
  floating.environment = "table*")


#
# TODO advanced timing
# difficulty vs time?
# difficulty vs course level (i.e. cs-1, architecture, etc)?
#
#

#
# TODO plot CQ movements on grid between votes
# can we see a visual pattern for good and bad questions?
#

#
# TODO normalized gain
# questions with space for improvement that don't improve
# questions with space for improvement that DO improve
# fraction of easy, medium, and hard questions
#

# get only the UIC courses (which have been tagged)
uicses = ses[grep("UIC", ses$course_name),]


# OK, R is a terrible language and using "+" to populate a scatterplot with points
#   is not intuitive syntax, to say the least.
go = function() {

ggplot(subset(ses, question_type == 3 & num_correct_answers == 1),
  aes(pct1st_correct, pct2nd_correct)) +
  geom_point(aes(color = course_name), alpha = 0.1) +
  scale_y_reverse( lim=c(1.0,0.0))
}

go()
