require 'csv'

class DataController < ApplicationController
  include ApplicationHelper

  # -----------------------------------------
  # GET /data
  #
  # This returns the data for all classes in csv format (csv or json, once
  #   I figure out how to create json):
  #
  # course_id course_name class_id class_name
  # qid num_seconds question_index question_type
  # num_correct_answers num1st num2nd
  # num1st_correct num2nd_correct pct1st_correct pct2nd_correct
  #
  def index
    # I'm using raw SQL instead of ActiveRecord. Sue me.
    #
    # This is such a shit way to have to do this, but ActiveRecord doesn't have
    #   any way to send more than one sql statement at a time, and I wanted to keep
    #   all the statements in one big string that is easy to put into a SQL file
    #   for testing against the DB from the command line.
    #
    # This split produces 6 queries
    # query[0]: First, delete the temp table, if it exists
    # query[1..4]: The next 3 queries create and populate the temp table
    # query[4]: The 5th query does our select using the temp table we just created
    # query[5]: Finally, the 6th and final query deletes the temp table.
    queries = csvsql().split(';')

    queries[0..4].each do |sql|
      ActiveRecord::Base.connection.exec_query(sql)
    end
    results = ActiveRecord::Base.connection.exec_query(queries[4])
    ActiveRecord::Base.connection.exec_query(queries[5])

    # https://stackoverflow.com/questions/39066365/smartly-converting-array-of-hashes-to-csv-in-ruby
    header = ['course_id', 'course_name', 'instructor', 'class_id', 'class_code',
    'qid', 'question_index', 'question_type',
    'num_correct_answers', 'num1st', 'num2nd',
    'num1st_correct', 'num2nd_correct',
    'pct1st_correct', 'pct2nd_correct',
    'seconds_1st', 'seconds_2nd',
    'normalized_gain']

    csv = header.to_csv
    results.each do |row|
      # Compute normalized gain. It's easier to compute here than in the
      #   database with SQL.
      row['normalized_gain'] = -1
      if row['question_type'] == 3
        pct1st = row['pct1st_correct'].to_f
        pct2nd = row['pct2nd_correct'].to_f
        row['normalized_gain'] = (pct2nd - pct1st) / (1 - pct1st)
      end
      # Holy crap, I'm combing the splat (*) operator with
      #   the map method and a block!
      csv += row.values_at(*header).map{|s| s.to_s.strip}.to_csv
    end

    # TODO Support json as well as csv.
    send_data csv,
      filename: "courses.csv",
      type: "text/plain; charset=us-ascii"

    # We can't redirect here because send_data is an http response
  end

private

  def query(sql)
    return ActiveRecord::Base.connection_pool.with_connection {
      |con| con.exec_query( sql )
    }
  end

  # ------------------------------------------
  # Sort of a hack. I couldn't figure out how to make the sql query
  # a private variable, so I'm making the SQL query a helper method that
  # just returns the sql query string.
  # I really want the sql query to be one big string, and to live in the same
  # file as the db code that invokes it, so that changing them together
  # is simlper and easier.
  # FIXME Figure out how to make this an actual variable.
  # XXX This sql query cannot have comments with semicolons in it! We are
  #   splitting this query as a string using the semicolons as delimiters.
  def csvsql
return %q{
-- delete the temp table, if it exists
drop table if exists qtemp;
--
-- PAIRED QUESTIONS
-- type 3 (paired)
--
create temp table qtemp as
select
q1.id as q1id, q2.id as q2id,
  q1.correct_a + q1.correct_b + q1.correct_c + q1.correct_d + q1.correct_e
as num_correct_answers,
  (q1.response_a + q1.response_b + q1.response_c + q1.response_d + q1.response_e)
as num1st,
  (q2.response_a + q2.response_b + q2.response_c + q2.response_d + q2.response_e)
as num2nd,
  (q1.response_a * q1.correct_a +
  q1.response_b * q1.correct_b +
  q1.response_c * q1.correct_c +
  q1.response_d * q1.correct_d +
  q1.response_e * q1.correct_e)
as num1st_correct,
  (q2.response_a * q2.correct_a +
  q2.response_b * q2.correct_b +
  q2.response_c * q2.correct_c +
  q2.response_d * q2.correct_d +
  q2.response_e * q2.correct_e)
as num2nd_correct,
  to_char((q1.response_a * q1.correct_a +
  q1.response_b * q1.correct_b +
  q1.response_c * q1.correct_c +
  q1.response_d * q1.correct_d +
  q1.response_e * q1.correct_e)::float /
  (q1.response_a + q1.response_b + q1.response_c + q1.response_d + q1.response_e), '0.99')
as pct1st_correct,
  to_char((q2.response_a * q2.correct_a +
  q2.response_b * q2.correct_b +
  q2.response_c * q2.correct_c +
  q2.response_d * q2.correct_d +
  q2.response_e * q2.correct_e)::float /
  (q2.response_a + q2.response_b + q2.response_c + q2.response_d + q2.response_e), '0.99')
as pct2nd_correct,
q1.num_seconds as seconds_1st,
q2.num_seconds as seconds_2nd
from questions q1, questions q2
where q1.class_period_id = q2.class_period_id
and q1.question_type = 3
and q2.question_type = 3
and q1.question_pair = q2.question_index
-- need at least one response per question
and q1.response_a + q1.response_b + q1.response_c + q1.response_d + q1.response_e > 0
and q2.response_a + q2.response_b + q2.response_c + q2.response_d + q2.response_e > 0
-- at least one correct answer for a pair, since we can't compute percentages without that
and q1.correct_a + q1.correct_b + q1.correct_c + q1.correct_d + q1.correct_e > 0
-- canonical ordering
and q1.id < q2.id;

--
-- SINGLE QUESTIONS
-- type 1, 2 (quiz, single)
--
insert into qtemp
select
q1.id as q1id, -1 as q2id,
  q1.correct_a + q1.correct_b + q1.correct_c + q1.correct_d + q1.correct_e
as num_correct_answers,
  (q1.response_a + q1.response_b + q1.response_c + q1.response_d + q1.response_e)
as num1st,
-1 as num2nd,
  (q1.response_a * q1.correct_a +
  q1.response_b * q1.correct_b +
  q1.response_c * q1.correct_c +
  q1.response_d * q1.correct_d +
  q1.response_e * q1.correct_e)
as num1st_correct,
-1 as num2nd_correct,
  to_char((q1.response_a * q1.correct_a +
  q1.response_b * q1.correct_b +
  q1.response_c * q1.correct_c +
  q1.response_d * q1.correct_d +
  q1.response_e * q1.correct_e)::float /
  (q1.response_a + q1.response_b + q1.response_c + q1.response_d + q1.response_e), '0.99')
as pct1st_correct,
-1 as pct2nd_correct,
q1.num_seconds as seconds_1st,
-1 as seconds_2nd
from questions q1
where q1.question_type in (1, 2)
-- at least one response to prevent divide by zero
-- at least one correct answer so that it's not bad data
and q1.correct_a + q1.correct_b + q1.correct_c + q1.correct_d + q1.correct_e > 0
and q1.response_a + q1.response_b + q1.response_c + q1.response_d + q1.response_e > 0;

--
-- non-MCQ QUESTIONS
-- type 4
-- Using clicker as a timer or for confidence votes
--
insert into qtemp
select
q1.id as q1id, -1 as q2id,
  q1.correct_a + q1.correct_b + q1.correct_c + q1.correct_d + q1.correct_e
as num_correct_answers,
  (q1.response_a + q1.response_b + q1.response_c + q1.response_d + q1.response_e)
as num1st,
-1 as num2nd,
  (q1.response_a * q1.correct_a +
  q1.response_b * q1.correct_b +
  q1.response_c * q1.correct_c +
  q1.response_d * q1.correct_d +
  q1.response_e * q1.correct_e)
as num1st_correct,
-1 as num2nd_correct,
-1 as pct1st_correct,
-1 as pct2nd_correct,
q1.num_seconds as seconds_1st,
-1 as seconds_2nd
from questions q1
where q1.question_type = 4;

select c.id as course_id, c.folder_name as course_name, c.instructor,
cp.id as class_id, cp.session_code as class_code,
q.id as qid, q.question_index, q.question_type,
qt.num_correct_answers, qt.num1st, qt.num2nd, qt.num1st_correct, qt.num2nd_correct,
qt.pct1st_correct, qt.pct2nd_correct,
qt.seconds_1st, qt.seconds_2nd
from courses c, class_periods cp, questions q, qtemp qt
where c.id = cp.course_id
and cp.id = q.class_period_id
and q.id = qt.q1id;

-- delete temporary table
drop table qtemp;
}
  end

end
