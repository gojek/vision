class Approval < ActiveRecord::Base
  belongs_to :change_request
  belongs_to :user

  def self.setup_for_change_request(change_request, approver_ids)
  	current_approver_ids = Approval.where(change_request_id: change_request.id).pluck(:user_id)
    deleted_approver_ids = current_approver_ids - approver_ids
    approver_ids = approver_ids - current_approver_ids
    if deleted_approver_ids.present?
      Approval.where(change_request_id: change_request.id, user_id: deleted_approver_ids).destroy_all
    end
    Approval.create(approver_ids.map { |approver_id| 
    	{ 
    		user_id: approver_id, 
    	  change_request_id: change_request.id
    	}
   	})
  end

end
