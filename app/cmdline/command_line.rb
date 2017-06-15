# Configuration for running from the command line with ActiveRecord

# Require ActiveRecord
require 'active_record'

# Setup the listed gems in the gemfile
require 'bundler/setup'

# Actually require the gems
Bundler.require

# Setup ActiveRecord
require 'logger'
ActiveRecord::Base.configurations = YAML.load_file('config/database.yml')
#ActiveRecord::Base.establish_connection(:default)
ActiveRecord::Base.establish_connection(:development)
ActiveRecord::Base.logger = Logger.new(STDOUT)
old_logger = ActiveRecord::Base.logger
ActiveRecord::Base.logger = nil

# Set up a logger for command-line logging.
$logger = Logger.new(STDOUT)
$logger.level = :info
$logger.datetime_format = '%Y-%m-%d %H:%M:%S'
