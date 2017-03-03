class IncidentReportMailer < ApplicationMailer
  default from: "vision@midtrans.com"

  def send_csv(ir_csv, email)
    attachments['incident_report.csv'] = {mime_type: 'text/csv', content: ir_csv}
    mail(to: email, subject: 'Incident Report CSV', body: 'Incident Request CSV.')
  end
end