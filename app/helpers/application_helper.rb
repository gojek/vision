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
end
