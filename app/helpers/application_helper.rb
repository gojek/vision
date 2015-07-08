module ApplicationHelper
	def is_release_manager
		current_user.role == "release_manager"
	end
	def count
    	Approver.where(approve: nil).where(user_id: current_user.id).count
  	end
  	def is_approver
  		current_user.role == "approver"
  	end
  	def is_scheduled
  		@change_request.status == 'Scheduled'
  	end
  	def is_deployed
  		@change_request.status == 'Deployed'
  	end
  	def is_submitted
  		@change_request.status == 'Submitted'
  	end
    def is_rollbacked
      @change_request.status == 'Rollbacked'
    end
    def is_cancelled
      @change_request.status == 'Cancelled'
    end
    def is_rejected
      @change_request.status == 'Rejected'
    end
end
