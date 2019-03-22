class ApplicationMailer < ActionMailer::Base
  require 'sucker_punch/async_syntax'

  default from: "narendra.hanif@veritrans.co.id"
  layout 'mailer'
end
