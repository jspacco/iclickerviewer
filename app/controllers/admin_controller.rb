class AdminController < ApplicationController
  before_action :require_verification?
  def index
    @users = User.all.order(:verification)

  end

  def update
    puts "Hey Yall We Doing Good"
    puts params[:users]
    @users = User.all.order(:verification)
    @users.each do |user|
      user.update_attributes(user_params(user))
    end
    render :index
  end

  def user_params(user)
    return params.require(:users).require(user.id.to_s).permit(:verification)
  end


  private

  def require_verification?
    unless current_user && current_user.verification >=2
      flash[:error]="Please Sign In with Appropriate Verification Level To Access This Page."
      redirect_to root_path
    end
  end

end
