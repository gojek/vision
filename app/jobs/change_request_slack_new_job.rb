class ChangeRequestSlackNewJob 
  include SuckerPunch::Job 

  def perform(change_request)
    SlackNotif.new.notify_new_cr change_request
  end
end
