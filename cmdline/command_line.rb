class String
  # Awesome use of Ruby's Open Classes!
  # I'm adding a method that checks that if a String can be converted to an int
  # https://stackoverflow.com/questions/1235863/test-if-a-string-is-basically-an-integer-in-quotes-using-ruby
  def is_i?
     /\A[-+]?\d+\z/ === self
  end
end

# Configure database for command-line uses of rails runner.
# Use DATABASE_URL if available, or else use the config/database.yml.
# https://stackoverflow.com/questions/5891529/standalone-ruby-how-to-load-different-environments-from-database-yml
#
if ENV.has_key?('DATABASE_URL')
  puts "Using DATABASE_URL #{ENV['DATABASE_URL']}"
  ActiveRecord::Base.establish_connection(ENV['DATABASE_URL'])
else
  puts "No DATABASE_URL found"
  environment = ENV['RACK_ENV'] || ENV['RAILS_ENV'] || 'development'
  puts "Using environment #{environment}"
  dbconfig = YAML.load(File.read('config/database.yml'))
  if !dbconfig[environment].has_key?('pool') || !dbconfig[environment]['pool'].is_i?
    dbconfig[environment]['pool'] = 2
  end
  puts "Connection pool size is #{dbconfig[environment]['pool']}"
  ActiveRecord::Base.establish_connection dbconfig[environment]
end
