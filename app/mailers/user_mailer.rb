class UserMailer < ApplicationMailer
	default from: "narendra.hanif@veritrans.co.id"

	def notif_email(user, change_request, status)
		@user = user
		@change_request = change_request
		@status = status
		@url = change_request_url(@change_request)
		@state = @status.status
		@reason = @status.reason
		@summary = change_request.change_summary
		@deploy  = change_request.schedule_change_date.to_s(:long)

		@recepients = User.where(:role => ['approver','release_manager'])
		if @recepients.count > 1
			approvers = @recepients.collect(&:email).join(",")
		else
			approvers = @recepients.collect(&:email)
		end
		mail(to: [@user.email,approvers], subject:'Change Request Status Changed')
	end
	def cab_email(cab)
		@date = cab.meet_date.to_s(:long)
		@room = cab.room
		@notes = cab.notes
		@change_requests = cab.change_requests
		@recepients = User.where(:role => ['approver','release_manager'])
		@all_recepients = @recepients.collect(&:email)
		@change_requests.each do |change_request| 
			@all_recepients.push(change_request.user.email)
		end
		approvers = @all_recepients.join(",")
		mail(to: approvers, subject:'New CAB Meeting')
	end

end
