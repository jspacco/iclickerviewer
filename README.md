# README

## TODO (code)
* accounts to prevent randos from changing our data
  * salt, hashing, sessions, all that stuff
* TODO: commands to blow up remote heroku DB and replace with new one
* TODO: upload images to s3, and set stupid permissions correctly
  * http://docs.aws.amazon.com/AmazonS3/latest/dev/CopyingObjectUsingRuby.html
* TODO: figure out how to use rails test
* color backgrounds grey that have not been set yet (i.e. no correct answer,
  no pair for a paired question, etc)
* FIXME: disallow changing type when it is set to pair, or directly setting to pair
* settings (hide/show spurious, etc)
* identify that two questions are "the same" across courses
  * JS to show images from other courses, with a button to enter into the form
* Update the column tooltips for sessions
* TODO (longterm): Somehow link from CQ to slide, and from slide to CQ
  * embedded PDF slide display tool
* TODO: web-based importer for the zipfile
  * basically a generalization of parse.rb
  * would probably need to use heroku+s3 to upload images to s3 automatically,
    which would be slow and would probably timeout often
* FIXME: command_line.rb and parse.rb were moved and won't load anymore
* back buttons and/or breadcrumbs in the style or header info
* are helpers usable in controllers or just in views?
  * What I was trying to do (global utility function) required using lib to create a module
* session#show: correct stats when we have correct answers
* session#show: aggregate stats at the top (times, percentages)
* overall stats for courses (course#index and course#show)
* add view for /question/:id
  * allow comments
* comment feature for other faculty
  * talk to other faculty about what they want to do with each question
  * durable links to questions for comments linking to questions from outside the Rails app (Google Docs, etc)
* zoomable or modal pictures (low priority)
  * https://www.w3schools.com/howto/howto_css_modal_images.asp
  * https://www.w3schools.com/jquerymobile/tryit.asp?filename=tryjqmob_popup_image
* fix full path needed in config/database.yml for sqlite3 when running cmdline
  * this may go away when we switch to mariadb or postgres
* server-side logging for views (and controllers)
* upload Dan Z's data
## TODO (logistics)
* email Dave, Leo, other collaborators
* IRB at Knox

## TODO (deployment)
* streamline uploading of database
* figure out why heroku rake db:migrate isn't working
  * fixed this by changing the migrations to go in order of the foreign keys,
  but still not sure why this was necessary on heroku but not locally.

## TODO (design)
* a logo?
* CSS of some kind?

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
