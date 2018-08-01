class ApplicationMailer < ActionMailer::Base
  default from: 'fake_email@sbcglobal.net'
  layout 'mailer'

  def sample_email(some_user)
    @some_user = some_user
    mail(to: 'errolk70@gmail.com', subject: 'New User')
  end
end
