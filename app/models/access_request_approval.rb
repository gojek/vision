class AccessRequestApproval < ApplicationRecord
  belongs_to :access_request
  belongs_to :user

  validates :notes, presence: true, if: :decided?

  def decided?
    return !self.approved.nil?
  end

  def self.setup_for_access_request(access_request, approver_ids)
    current_approver_ids = access_request.persisted? ? 
      AccessRequestApproval.where(access_request_id: access_request.id).pluck(:user_id) : []
    deleted_approver_ids = current_approver_ids - approver_ids
    approver_ids = approver_ids - current_approver_ids
    AccessRequestApproval.where(access_request_id: access_request.id, user_id: deleted_approver_ids).destroy_all
    AccessRequestApproval.create(
      approver_ids.map do |approver_id|
        {
          access_request_id: access_request.id,
          user_id: approver_id
        }
      end
    )
  end
end
