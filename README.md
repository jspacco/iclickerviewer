# README

## TODO (code)
* mark paired CQs (model and UI)
* mark individual CQs (model and UI)
* mark wrong/spurious/uninteresting CQs (model and UI)
* identify that two questions are "the same" across courses
  * many-to-many model
* back buttons and/or breadcrumbs
* are helpers usable in controllers or just in views?
* session#show: correct stats when we have correct answers
* session#show: aggregate stats at the top (times, percentages)
* overall stats for courses (course#index and course#show)
* comment feature for other faculty
  * talk to other faculty about what they want to do with each question
  * durable links to questions for comments linking to questions from outside the   Rails app
* zoomable or modal pictures
  * https://www.w3schools.com/howto/howto_css_modal_images.asp
  * https://www.w3schools.com/jquerymobile/tryit.asp?filename=tryjqmob_popup_image
* fix full path needed in config/database.yml for sqlite3 when running cmdline
  * this may go away when we switch to mariadb or postgres
* why does sqlite3 only work with a threadpool of size 1?
* server-side logging for views (and controllers)
* upload Dan Z's data
## TODO (logistics)
* email Dave, Leo, other collaborators
## TODO (deployment)
* configure maria or postgres
  * development
  * heroku
* deploy to heroku through github
* how to handle 166+ MB of images on heroku
  * don't want to commit them all to github
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
