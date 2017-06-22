# README

## TODO (code)
* mark paired and individual CQs (model and UI)
  * unknown, individual, spurious, paired, non-MCQ
    * unknown (have not processed)
    * individual (only one vote)
    * spurious (mis-click, spurious click, not a clicker question)
    * non-MCQ use of clicker (basically an in-class activity that used the clicker as a timer)
    * paired CQ
      * partner question is a separate column that defaults to NULL
  * can we use JS to enforce some properties, like anytime you choose a paired partner, the pair automatically become "pair" and cannot be changed
  * using before_save in the model to convert empty string to nil
* settings (hide/show spurious, etc)
* identify that two questions are "the same" across courses
  * many-to-many model
* Somehow link from CQ to slide, and from slide to CQ
  * embedded PDF slide display tool
* accounts to prevent randos from changing our data
* back buttons and/or breadcrumbs in the style or header info
* are helpers usable in controllers or just in views?
  * What I was trying to do (global utility function) required using lib to create a module
* session#show: correct stats when we have correct answers
* session#show: aggregate stats at the top (times, percentages)
* overall stats for courses (course#index and course#show)
* comment feature for other faculty
  * talk to other faculty about what they want to do with each question
  * durable links to questions for comments linking to questions from outside the Rails app (Google Docs, etc)
* zoomable or modal pictures (low priority)
  * https://www.w3schools.com/howto/howto_css_modal_images.asp
  * https://www.w3schools.com/jquerymobile/tryit.asp?filename=tryjqmob_popup_image
* fix full path needed in config/database.yml for sqlite3 when running cmdline
  * this may go away when we switch to mariadb or postgres
* why does sqlite3 only work with a threadpool of size 1?
* server-side logging for views (and controllers)
* upload Dan Z's data
## TODO (logistics)
* email Dave, Leo, other collaborators
* IRB at Knox
## TODO (deployment)
* configure mariadb or postgres
  * development
  * mariadb/postreg on heroku
* deploy to heroku through github
* how to handle 166+ MB of images on heroku
  * don't want to commit them all to github!
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
