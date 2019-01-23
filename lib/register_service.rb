class RegisterService

	def create_or_signin_user(is_new_user, user)
		is_signin = false
		if user.valid?
      user.save
      if is_new_user || user.is_approved == User::NOT_YET_FILL_THE_FORM
        is_signin = true
        return is_signin, register_path, { alert: 'Please fill the form to requesting your access.' }, false
      elsif user.is_approved == User::WAITING_FOR_APPROVAL
        return is_signin, signin_path, { alert: 'Your account is not yet approved to open Vision' }, false
      elsif user.is_approved == User::REJECTED
        return is_signin, signin_path, { alert: 'Sorry, your access request to Vision is rejected.' }, false
      else
        is_signin = true
        return is_signin, root_path, {}, true
      end
     else
      if !user.use_company_email?
        err_message = 'Please use company email'
      else
        err_message = 'Authentication failed!'
      end
      return is_signin, root_path, flash: { alert: err_message }
    end
	end


end