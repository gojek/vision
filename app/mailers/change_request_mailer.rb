class ChangeRequestMailer < ApplicationMailer
  default from: ENV['VISION_EMAIL']

  def send_csv(cr_csv, email)
    attachments['change_requests.csv'] = {mime_type: 'text/csv', content: cr_csv}
    mail(to: email, subject: 'Change Requests CSV', body: 'Change requests csv.')
  end
end
