class AccessRequest < ActiveRecord::Base
  before_save :create_access_request_status

  include AASM
  belongs_to :user
  has_and_belongs_to_many :collaborators, join_table: :access_request_collaborators, class_name: 'User'
  has_many :approvals, join_table: :access_request_approvals, dependent: :destroy, class_name: 'AccessRequestApproval'
  has_many :statuses, join_table: :access_request_statuses, dependent: :destroy, class_name: 'AccessRequestStatus'

  REQUEST_TYPE = %w(Create Delete Modify)
  ACCESS_TYPE = %w(Permanent Temporary)

  validates :approvals, presence: true
  validates :request_type, inclusion: { in: REQUEST_TYPE, message: '%{value} is not a valid scope' }
  validates :access_type, inclusion: { in: ACCESS_TYPE, message: '%{value} is not a valid scope' }
  validates :start_date, :end_date, presence: true, if: :temporary?
  validates :employee_name, :employee_position, :employee_email_address, :employee_department, :employee_phone, 
            presence: true

  attr_accessor :reason

  aasm do
    state :draft, :initial => true
    state :submitted
    state :succeeded
    state :cancelled

    event :submit do
      transitions :from => :draft, :to => :submitted
    end
    event :close do
      transitions :from => :submitted, :to => :succeeded, :guard => :closeable?
    end
    event :cancel do
      transitions :from => :submitted, :to => :cancelled
    end
  end

  def temporary?
    self.access_type == 'Temporary'
  end

  def duration
    (self.end_date - self.start_date).to_i
  end

  def approved_count
    self.approvals.where(approved: true).count
  end

  def rejected_count
    self.approvals.where(approved: false).count
  end

  def approval_status
    return 'none' if self.draft?
    return 'failed' if rejected_count > 0
    self.closeable? ? 'success' : 'on progress'
  end

  def editable?(user)
    return ((self.user == user) || user.is_admin || (self.collaborators.include? user)) &&
      !self.terminal_state? && !self.has_approver?(user)
  end

  def set_approvers(approver_id_list)
    self.approvals.delete_all
    approver_id_list.each do |approver_id|
      approver = User.find(approver_id)
      approval = AccessRequestApproval.create(user: approver)
      self.approvals << approval
    end
  end

  def set_collaborators(collaborator_id_list)
    self.collaborators = []
    collaborator_id_list.each do |collaborator_id|
      self.collaborators << User.find(collaborator_id)
    end
  end

  def previous
    AccessRequest.where(["id > ?", id]).first
  end

  def next
    AccessRequest.where(["id < ?", id]).last
  end

  def create_access_request_status
    unless self.statuses.new(:status => self.aasm_state, :reason => self.reason).valid?
      self.aasm_state = self.changes['aasm_state'].first
      return false
    end
  end

  def terminal_state?
    return self.cancelled? || self.succeeded?
  end

  def state_require_note?(state)
    states = [:cancel]
    states.include? state
  end

  def next_states
    return self.aasm.events(:permitted => true).map(&:name)
  end

  def current_state
    return self.aasm.current_event
  end

  def closeable?
    self.approvals.count > 0  && approved_count == self.approvals.count
  end

  def has_approver?(user)
    AccessRequestApproval.where(access_request_id: id, user_id: user.id).any?
  end
  
  def is_associate?(user)
    stakeholders = [self.user] + self.collaborators + (self.approvals.map { |approval| approval.user })
    stakeholders.include? user
  end

  def is_approved?(user)
    AccessRequestApproval.where(access_request_id: id, user_id: user.id).first.approved
  end
end
