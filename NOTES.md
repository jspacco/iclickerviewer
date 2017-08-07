MODELS COMMANDS
---
In case I need to make changes... These are the rails commands to create the database model:

bin/rails g model course name term year:integer institution instructor folder_name

bin/rails g model session session_code name participation performance\
  min_response min_response_string date:datetime course:references

bin/rails g model question name start stop\
  num_seconds:integer question_index:integer\
  response_a:integer response_b:integer\
  response_c:integer response_d:integer response_e:integer\
  correct_a:integer correct_b:integer correct_c:integer correct_d:integer\
  correct_e:integer is_deleted session:references
bin/rails g migration AddDetailsToQuestion\
  question_type:integer question_pair:integer
  # need to set null default for question_pair in migration file

bin/rails g model vote clicker_id first_answer_time:float\
  total_time:float num_attempts:integer loaned_clicker_to\
  first_response response question:references

CONTROLLERS
---
bin/rails generate controller Courses
bin/rails generate controller ClassPeriods
bin/rails generate controller Sessions new
bin/rails generate controller Questions

OTHER NOTES
---
* validators cannot be created through the rails model generator. So it's
  not clear how to keep models and migrations up to date if you change the name
  of a table with a migration, and then also change its validator.

* all of these functions are confusing:
    http://guides.rubyonrails.org/routing.html#path-and-url-helpers

* find_all_by has been replaced by where:
    https://stackoverflow.com/questions/12057790/have-find-by-in-rails-return-multiple-results

HEROKU
---
* local postgres:
  create role iclickerviewer with createdb login password iclickerviewer;

* heroku pg:info
  * heroku pg:credentials postgresql-parallel-76813
  * heroku pg:reset
  * heroku pg:psql
* to push from local DB to heroku:

  PGUSER=iclickerviewer PGPASSWORD=iclickerviewer heroku pg:push iclickerviewer postgresql-parallel-76813

* To connect command line to Heroku:
  https://devcenter.heroku.com/articles/connecting-to-heroku-postgres-databases-from-outside-of-heroku
  DATABASE_URL=$(heroku config:get DATABASE_URL -a your-app) your_process

* Had to re-name all of the migrations so that they happen in the order in which
  the primary keys are needed (i.e. courses, then sessions which ref courses,
  then questions which ref sessions, then votes which ref questions).
  * could be postgres v9.4 (local) vs postgres v9.6 (heroku)

* Check rails config:
  RAILS_ENV=production rake about

* The power of renaming a migration:
  https://stackoverflow.com/questions/753919/run-a-single-migration-file

* To create a single user in the Rails console (rails console full)

User.new(name: "T Honor Goat", email: "thgoat@example.com", username: "thgoat", password: "tiberius99", password_confirmation: "tiberius99")

Rails
--
* Rails error:
form_tag(session_path(@session), method: :patch)
  IS NOT THE SAME AS
form_tag url: session_path(@session), method: :path

The first one is correct, and creates a form for patching, which uses HTTP POST but sets a special \_method hidden parameter.

The 2nd one creates a standard POST, and passes it a hash with keys "url" and "method" and the given values. This is an example of a place where all of the syntactic sugar provided by Ruby and Rails has definitely confused me.

* render :show in a controller re-directs the view ONLY. It does not call the
  show method of the controller, so any variables needed by the show view will need
  to be loaded by the current controller.

* Use .object to get at the underlying instance inside a FormBuilder

* before_action in controller:
  https://stackoverflow.com/questions/34330481/rails-options-for-select-send-nil-when-no-option-selected

* create unique index:
  https://stackoverflow.com/questions/1449459/how-do-i-make-a-column-unique-and-index-it-in-a-ruby-on-rails-migration

* has_many self-referential inverse
  * http://railscasts.com/episodes/163-self-referential-association
  * https://collectiveidea.com/blog/archives/2015/07/30/bi-directional-and-self-referential-associations-in-rails

* html multiple select using has_many through:
  https://stackoverflow.com/questions/8826407/rails-3-multiple-select-with-has-many-through-associations

* database.yml is processed with ERB when run inside Rails, which is how the
  ENV substitutions happen. However, command_line.rb needs to explicitly set
  these variables because reading the YAML file with Ruby ends up with the string
  literals. app/cmdline/command_line.rb contains a workaround.

* Not sure how to specify test vs development in database.yml; current everything
  is configured to use the default because otherwise test seems to be the default.
  * Try setting RAILS_ENV=test when running

* You can't open up page source in Chrome, and then reload the window showing the
  page source. This doesn't actually reload the original page, and won't do what
  I thought it did. There goes a day of my life :(

* check autoloads path:
  bin/rails r 'puts ActiveSupport::Dependencies.autoload_paths'

* javascript sort() method can take a function as a parameter, and use that function
  like a compareTo method.

* To install phashion, I needed to do 'brew install jpeg' because I got an error
  about -ljpeg not being available. Phashion uses native (i.e. compiled C) libraries
  that need to be installed for Ruby to use it. I also did
  gem install phashion -v '1.2.0'
  but I think that this also would have worked with the bundle installer.

* You need to grant SUPERUSER to the postgres account to run any of the tests
  https://stackoverflow.com/questions/30729723/ruby-on-rails-deleting-fixtures-with-foreign-keys
  ALTER USER iclickerviewer WITH SUPERUSER;

* For Rails testing, the test/fixtures folder is run to create things in the DB, so it
  needs to be modified or emptied because it may try to insert rows that violate
  foreign key constraints.

* To dump database to fixtures:
  https://gist.github.com/iiska/1527911

* To list everything in an AWS S3 bucket:
  https://stackoverflow.com/questions/3337912/quick-way-to-list-all-files-in-amazon-s3-bucket

* Model Callbacks, hopefully will make matching_questions easier to manage
  https://stackoverflow.com/questions/24310533/symmetrical-self-referential-habtm-relationship

* different kinds of updates in ActiveRecord
  http://www.davidverhasselt.com/set-attributes-in-activerecord/

* to run rails scripts from the command line:
  rails r cmdline/post_process_near_duplicates.rb

* To use a where clause on the many-to-many join table:
https://stackoverflow.com/questions/9033797/how-to-specify-conditions-on-joined-tables-in-rails
  matches = q1.matched_questions.where(:matching_questions => {:is_match => 1})

  This assumes that q1 is a Question, matched_questions is the symmetric name for
  a self-join back to the Question table through the matching_questions table. So
  we are applying a where clause to the matching_questions join table, not to either
  Question (q1) or matched_questions (which also a Question because it's a self-join).

  This trick with where clauses seems to work in general.

* For joins, we really use getters, but getting the plurality correct is annoying:
  https://stackoverflow.com/questions/25938632/rails-join-table-a-to-table-c-where-a-has-many-b-and-b-has-many-c
  Note that its ':has_many :itemS, through: :boxes'; it has to be plural for this to work (apparently)
