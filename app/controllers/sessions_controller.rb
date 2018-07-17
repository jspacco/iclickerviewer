class SessionsController < ApplicationController
  def new
  end

  def create
  #  user = User.find_by(username: params[:session][:username].downcase)
  #  if user && user.authenticate(params[:session][:password])
  #    log_in user
  #    redirect_to courses_url, action: :index
  #  else
  #    flash.now[:danger] = 'Invalid email/password combination'
  #    render :new
  #  end
  end

  def destroy
    sign_out
    flash.now[:notice] = 'You logged out'
    redirect_to root_url
  end
  #  flash.now[:notice] = 'You logged out'
  #  redirect_to root_url
  #end
end
