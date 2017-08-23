# TODO
Creating a more formal TODO list
---

## TODO (code)
* multiple sessions from the same day are actually the same class period; happens for Toronto a few times and this messes up tracking paired questions if the questions straddle this artificial break
* questions repeated within the same term (review sessions)
* Tagging of classes (i.e. regular class period, review session, others?)
* Time data for classes (days per week, minutes per class, number of weeks, total class periods scheduled)
* It looks like some questions are actually tripled, not just paired
* automatically upload images to s3, and set stupid permissions correctly
  * http://docs.aws.amazon.com/AmazonS3/latest/dev/CopyingObjectUsingRuby.html
* JS disallow changing type when it is set to pair, or directly setting to pair
* settings (hide/show spurious, etc)
* more user accounts
* matching_questions
  * mark identical VS modified from /class_periods/:id
  * transitive relationships for matches, and for identical/modified
  * Improve potential matches using Phashion and/or OCR and/or slides
* DB should question_type default to 0 instead of empty string?
* (lowpri): auto mark correct answer when pairing
* Update the column tooltips for sessions
* how does flash for errors work in Rails?
* (longterm): Somehow link from CQ to slide, and from slide to CQ
  * embedded PDF slide display tool?
* (lowpri): web-based importer for the zipfile
  * basically a generalization of parse.rb
* breadcrumbs in header
  * go back to the current course
* filter by instructor, filter by class, select a group of classes
* collapsible full list of stuff
* (lowpri): use bootstrap tooltips instead of the ones I wrote
* session#show: correct stats when we have correct answers
* session#show: aggregate stats at the top (times, percentages)
* overall stats for courses (course#index and course#show)
* add view for /question/:id
  * allow comments or rankings
* comment feature for other faculty
  * talk to other faculty about what they want to do with each question
  * durable links to questions for comments linking to questions from outside the Rails app (Google Docs, etc)
* fix full path needed in config/database.yml for sqlite3 when running cmdline
  * this may go away when we switch to mariadb or postgres
* server-side logging for views (and controllers)
* upload Dan Z's data
* TODO: Fix helper methods so that they return values rather than
  set instance variables, in order to make testing easier
* TODO: can this be made into a callback or method of some kind?
q.matched_questions.where(:matching_questions => {:is_match => nil})

## TODO (logistics)
*
* IRB at Knox (awaiting response; ping Gabe and Andy again)
* two 450s and classes from Prague are 361s16 (Kanich)
  * FIXME: which are the other Kanich questions?

## TODO (deployment)
* streamline uploading of database
* figure out why heroku rake db:migrate isn't working
  * fixed this by changing the migrations to go in order of the foreign keys,
  but still not sure why this was necessary on heroku but not locally.

## TODO (design)
* a logo?
* CSS of some kind?

## Queries
* What's the average diff correct between first and second question?
  * split that out by class
  * split out by difficulty
* What's the distribution of easy/medium/hard questions?
  * across classes
* Identify questions where right answer percent goes down or is flat
  * not as exciting if it 90% stays flat
* Good question is something where there's an increase
