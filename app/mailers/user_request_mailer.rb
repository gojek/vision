class UserRequestMailer < ApplicationMailer
  default from: "narendra.hanif@veritrans.co.id"

  def approve_email(user)
    @user = user
    mail(to: @user.email, subject: 'Vision Access Request')
  end

  def reject_email(user)
    @user = user
    mail(to: @user.email, subject: 'Vision Access Request')
  end
end
