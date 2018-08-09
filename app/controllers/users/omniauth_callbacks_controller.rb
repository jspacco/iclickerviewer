class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def google_oauth2
    # Somehow sets current_user to the currently logged in user
    # Also, somehow creates lots of paths, like destroy_user_session_path
    # Not sure how Devise paths get created or added to the routes.
    # Devise does a lot of things that we should learn more about.
    @user = User.from_omniauth(request.env["omniauth.auth"])
    if @user.persisted?
      sign_in_and_redirect @user, :event => :authentication
      set_flash_message(:notice, :success, :kind => "Google") if is_navigational_format?
      if @user.sign_in_count<=100
        MailerMailer.with(user: @user).welcome_email.deliver_now
      end
    else
      session["devise.google_data"] = request.env["omniauth.auth"]
      redirect_to new_user_registration_url
    end
  end



  def failure
    redirect_to root_path
  end
end
