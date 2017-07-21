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

* Had to re-name all of the migrations so that they happen in the order in which
  the primary keys are needed (i.e. courses, then sessions which ref courses,
  then questions which ref sessions, then votes which ref questions).
  * could be postgres v9.4 (local) vs postgres v9.6 (heroku)

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
  http://railscasts.com/episodes/163-self-referential-association

* html multiple select using has_many through:
  https://stackoverflow.com/questions/8826407/rails-3-multiple-select-with-has-many-through-associations

* database.yml is processed with ERB when run inside Rails, which is how the
  ENV substitutions happen. However, command_line.rb needs to explicitly set
  these variables because reading the YAML file with Ruby ends up with the string
  literals. app/cmdline/command_line.rb contains a workaround.

* Not sure how to specify test vs development in database.yml; current everything
  is configured to use the default because otherwise test seems to be the default.

* check autoloads path:
  bin/rails r 'puts ActiveSupport::Dependencies.autoload_paths'

*