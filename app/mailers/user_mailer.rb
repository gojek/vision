class UserMailer < ApplicationMailer
	default from: "narendra.hanif@veritrans.co.id"

	def notif_email(user, change_request, status)
		@user = user
		@change_request = change_request
		@status = status
		@url = change_request_url(@change_request)
		@state = @status.status
		@reason = @status.reason
		@recepients = User.where(:role => ['approver','release_manager'])
		if @recepients.count > 1
			approvers = @recepients.collect(&:email).join(",")
		else
			approvers = @recepients.collect(&:email)
		end
		mail(to: [@user.email,approvers], subject:'Change Request Status Changed')
	end


end
