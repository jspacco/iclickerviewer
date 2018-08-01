class MailerMailer < ApplicationMailer
  default from: "iclickerviewer.notifications@gmail.com"
  def welcome_email
    @user = User.first
    @url = 'iclickerviewer.herokuapp.com'

    mail(to: 'ebkaylor@knox.edu', subject: 'Welcome to Iclickerviewer')
  end
end
