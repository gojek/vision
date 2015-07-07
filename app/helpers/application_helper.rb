module ApplicationHelper
	def is_release_manager
		current_user.role == "release_manager"
	end
end
