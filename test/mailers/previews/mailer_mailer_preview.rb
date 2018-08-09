# Preview all emails at http://localhost:3000/rails/mailers/mailer_mailer
class MailerMailerPreview < ActionMailer::Preview
  def sample_mail_preview
    MailerMailer.welcome_email
  end
end
