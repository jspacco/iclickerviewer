source('course_hash.r')
library(data.table)
library(Cairo)
library(ggplot2)

outdir = '/Users/jspacco/projects/clickers/sigcse2018'


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
num_classes = aggregate(class_id ~ course_id,
  data = unique(ses[,c('course_id','class_id')]),
  FUN = length)

# average number of questions per class period
# uses the number of questions per class periods per course
avg_cqs = aggregate(qid ~ course_id,
  data = aggregate(qid ~ course_id * class_id, data = ses, FUN = length),
  FUN = mean)

# total number of clicker questions per course
num_cqs = aggregate(qid ~ course_id, data = ses, FUN = length)

# OK, R is a terrible language and using "+" to populate a scatterplot with points
#   is not intuitive syntax, to say the least.
go = function() {
  df = ses[grep("UIC", ses$course_name),]

ggplot(subset(question_type == 3 & num_correct_answers == 1),
  aes(pct1st_correct, pct2nd_correct)) +
  geom_point(aes(color = course_name), alpha = 0.1) +
  scale_y_reverse( lim=c(1.0,0.0))
}

go()
