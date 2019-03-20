module UsersHelper

  def user_approved_status(user)
    if user.rejected?
      'Rejected'
    elsif user.pending?
      'Pending'
    elsif user.need_approvals?
      'Waiting for approval'
    else
      'Approved'
    end
  end
end
