class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  # before_action is a filter that is applied before we load the view
  before_action :authenticate_user!
  include SessionsHelper
  # include utility functions from lib/utilities.rb
  # include Utilities
  protected

  # To load a page, users either need to be logged in,
  #   or we need to be loading the /login page
  def authenticate_user!
    if !(logged_in? || request.fullpath.end_with?('/login'))
      redirect_to login_path, :notice => 'You need to log in first'
    end
  end
end
