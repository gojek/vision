module UsersHelper
	def admin?
		current_user.is_admin
	end
end
