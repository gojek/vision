class Notifier

  def self.cr_notify(whodunnit, change_request, message)

    notification_receiver = []
    #get the cr approver
    notification_receiver = notification_receiver + change_request.approvals.collect(&:user)

    #get the cr collaborators
    notification_receiver = notification_receiver + change_request.collaborators

    #add the requestor
    notification_receiver << change_request.user

    #add release_manager
    notification_receiver = notification_receiver + User.where(role: 'release_manager')

    #remove duplicate
    notification_receiver = notification_receiver.uniq

    #substract the whodunnit from user list
    notification_receiver = notification_receiver - [whodunnit]

    #create it
    notification_receiver.each do |receiver|
    	Notification.create({
    		user: receiver,
    		change_request: change_request,
    		message: message
    		})
    end
  end

  def self.ar_notify(whodunnit, access_request, message)
    notification_receiver = []
    notification_receiver = notification_receiver + access_request.approvals.collect(&:user)
    notification_receiver = notification_receiver + access_request.collaborators
    notification_receiver << access_request.user
    notification_receiver = notification_receiver + User.where(role: 'release_manager')
    notification_receiver = notification_receiver.uniq
    notification_receiver = notification_receiver - [whodunnit]

    notification_receiver.each do |receiver|
      Notification.create({
        user: receiver,
        access_request: access_request,
        message: message
      })
    end
  end

  #incident report notification
  def self.ir_notify(whodunnit, incident_report, message)
  	notification_receiver = []

  	#add all user
  	notification_receiver = notification_receiver + User.all

  	#substract the whodunnit from user list
  	notification_receiver.each do |receiver|
  		Notification.create({
  			user: receiver,
  			incident_report: incident_report,
  			message: message
  			})
	  end
	end

  def self.cr_read(user,change_request)
    user.notifications.where(change_request: change_request).delete_all
  end

  def self.ir_read(user, incident_report)
    user.notifications.where(incident_report: incident_report).delete_all
  end

  def self.mark_all_as_read(user)
    user.notifications.delete_all
  end

end
