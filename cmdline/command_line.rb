# Configuration for running from the command line with ActiveRecord

puts "Dammit, is this being called?\n\n\n"

# Require ActiveRecord
require 'active_record'

# Setup the listed gems in the gemfile
require 'bundler/setup'

# Actually require the gems
Bundler.require

# Setup ActiveRecord
require 'logger'
ActiveRecord::Base.configurations = YAML.load_file('config/database.yml')
database = ENV.key?('RAILS_ENV') ? ENV['RAILS_ENV'] : :default

#ActiveRecord::Base.establish_connection(:development)
# FIXME Command line Ruby doesn't seem to be able to substitute ERB syntax
#   so we have to manually set the size of the database connection pool
#   and the database password.
ActiveRecord::Base.configurations[database.to_s]['pool'] = 5 if !ActiveRecord::Base.configurations[database.to_s].key?('pool')
ActiveRecord::Base.configurations[database.to_s]['password'] = ENV['RAILS_DATABASE_PASSWORD'] if !ActiveRecord::Base.configurations[database.to_s].key?('pool')

# FIXME Read the database connection category from command line or env.
ActiveRecord::Base.establish_connection(database)

ActiveRecord::Base.logger = Logger.new(STDOUT)
old_logger = ActiveRecord::Base.logger
ActiveRecord::Base.logger = nil

# Set up a logger for command-line logging.
$logger = Logger.new(STDOUT)
$logger.level = :info
$logger.datetime_format = '%Y-%m-%d %H:%M:%S'
