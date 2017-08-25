class AccessRequest < ActiveRecord::Base
  include AASM
  belongs_to :user
  has_and_belongs_to_many :collaborators, join_table: :access_request_collaborators
  has_many :approvals, join_table: :access_request_approvals, dependent: :destroy

  REQUEST_TYPE = %w(Create Delete Modify)

  aasm do
    state :draft, :initial => true
    state :submitted
    state :applied
    state :cancelled

    event :submit do
      transitions :form => :draft, :to => :submitted
    end
    event :applied do
      transitions :from => :submitted, :to => :applied
    end
    event :cancel do
      transitions :from => :submitted, :to => :cancelled
    end
  end

  def approved_count
    self.approvals.where(approve: true).count
  end

  def rejected_count
    self.approvals.where(approve: false).count
  end

  def approval_status
    return 'failed' if rejected_count > 0
    self.approved_count == self.approvals.count ? 'success' : 'on progressa'
  end

  def editable?(user)
    return (self.user == user) || user.is_admin || (self.collaborators.include? user)
  end
end
