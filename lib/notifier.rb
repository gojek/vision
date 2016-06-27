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
    		read: false,
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
  			read: false,
  			message: message
  			})
	  end
	end

  def self.cr_read(user,change_request)
    id = user.id
    cr_id = change_request.id
    Notification.where(:user_id => id,:change_request_id => cr_id).update_all(:read => true)
  end

  def self.ir_read(user, incident_report)
    id = user.id
    ir_id = incident_report.id
    Notification.where(:user_id => id, :incident_report_id => ir_id).update_all(:read => true)
  end

  def self.all_read(user)
    user.notifications.cr.each do |cr|
      cr.update(read: true)
    end
    user.notifications.ir.each do |ir|
      ir.update(read: true)
    end
  end

end
