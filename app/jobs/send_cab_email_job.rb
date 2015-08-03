class SendCabEmailJob < ActiveJob::Base
  queue_as :default

  def perform(cab)
  	@cab = cab
    UserMailer.cab_email(@cab).deliver_later
  end
end
