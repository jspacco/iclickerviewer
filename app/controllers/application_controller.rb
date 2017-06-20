class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  # include utility functions from elib/utilities.rb
  include Utilities
end
