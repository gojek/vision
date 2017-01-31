class ChangeRequestMailer < ApplicationMailer
	default from: "raden.septiandry@midtrans.com"

  def send_csv(cr_csv, email)
   attachments['my_file_name.csv'] = {mime_type: 'text/csv', content: cr_csv}
    mail(to: email, subject: 'My subject', body: 'My body.')
  end
end
