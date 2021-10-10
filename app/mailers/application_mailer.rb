class ApplicationMailer < ActionMailer::Base
  require 'sucker_punch/async_syntax'

  default from: "visonopensource2021@gmail.com"
  layout 'mailer'
end
