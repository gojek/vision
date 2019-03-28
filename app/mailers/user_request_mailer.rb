class UserRequestMailer < ApplicationMailer
  default from: ENV['VISION_EMAIL']

  def approve_email(user)
    @user = user
    mail(to: @user.email, subject: 'Vision Access Request')
  end

  def reject_email(user)
    @user = user
    @contact_email = ENV['CONTACT_EMAIL']
    mail(to: @user.email, subject: 'Vision Access Request')
  end
end
