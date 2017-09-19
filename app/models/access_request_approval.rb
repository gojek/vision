class AccessRequestApproval < ActiveRecord::Base
  belongs_to :access_request
  belongs_to :user

  validates :notes, presence: true, if: :decided?

  def decided?
    return !self.approved.nil?
  end
end
