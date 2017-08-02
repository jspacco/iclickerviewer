# README

## TODO (code)
* TODO: single script to copy local db, remove votes, and push to heroku
* TODO: pull heroku data and merge with missing votes
* TODO: upload images to s3, and set stupid permissions correctly
  * http://docs.aws.amazon.com/AmazonS3/latest/dev/CopyingObjectUsingRuby.html
* TODO: figure out how to use rails test
* FIXME: disallow changing type when it is set to pair, or directly setting to pair
* settings (hide/show spurious, etc)
* TODO: matching_questions
  * can be either identical or modified, property of the many-to-many row
  * FIXME: transitive relationships for matches, and for identical/modified
  * run phashion offline and produce a list of possible matches in a big text file
    * /path/to/file/img1.jpg => /path/to/file/img2.jpg
    * put in the session?
    * check into github?
    * single-row of DB?
    * how to handle new file uploads?
    * put on S3? (probably the right move)
* FIXME: question_type should default to 0, not to the empty string
* TODO (lowpri): mark correct answer when pairing
* TODO: Update the column tooltips for sessions
* TODO: how does flash work in Rails?
* TODO (longterm): Somehow link from CQ to slide, and from slide to CQ
  * embedded PDF slide display tool
* TODO (lowpri): web-based importer for the zipfile
  * basically a generalization of parse.rb
* TODO: breadcrumbs in header
  * go back to the current course
* TODO: filter by instructor, filter by class, select a group of classes
* TODO: collapsible full list of stuff
* FIXME (lowpri): use bootstrap tooltips instead of the ones I wrote
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

## TODO (logistics)
* email Dave, Leo, other collaborators
* IRB at Knox
* two 450s and classes from Prague are 361s16 (Kanich)

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

### Boilerplate README
This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...
