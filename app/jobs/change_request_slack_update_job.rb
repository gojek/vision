class ChangeRequestSlackUpdateJob 
  include SuckerPunch::Job 

  def perform(change_request, type)
    SlackNotif.new.notify_update_cr change_request
  end
end
