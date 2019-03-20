class AccessRequest < ActiveRecord::Base
  has_paper_trail

  before_save :create_access_request_status

  attr_accessor :approver_ids

  include AASM
  belongs_to :user
  has_and_belongs_to_many :collaborators, join_table: :access_request_collaborators, class_name: 'User'
  has_many :approvals, join_table: :access_request_approvals, dependent: :destroy, class_name: 'AccessRequestApproval'
  has_many :statuses, join_table: :access_request_statuses, dependent: :destroy, class_name: 'AccessRequestStatus'
  has_many :access_request_comments, dependent: :destroy
  has_many :notifications, dependent: :destroy
  TEMPORARY = 'Temporary'.freeze
  PERMANENT = 'Permanent'.freeze

  REQUEST_TYPES = %w(Create Delete Modify).freeze
  ACCESS_TYPES = [PERMANENT, TEMPORARY]
  DEFAULT_REQUEST_TYPE = 'Create'
  DEFAULT_ACCESS_TYPE = PERMANENT


  validates :approvals, presence: true
  validates :business_justification, presence: true
  validates :request_type, inclusion: { in: REQUEST_TYPES, message: '%{value} is not a valid scope' }
  validates :access_type, inclusion: { in: ACCESS_TYPES, message: '%{value} is not a valid scope' }
  validates :start_date, :end_date, presence: true, if: :temporary?
  validates :employee_name, :employee_position, :employee_email_address, :employee_department, :employee_phone,
            presence: true

  attr_accessor :reason

  searchable auto_index: false do
    text :employee_name, stored: true
    text :employee_position, stored: true
    text :employee_email_address, stored: true
    text :employee_department, stored: true
    text :employee_phone, stored: true
    time :created_at, stored: true
  end

  aasm do
    state :draft, :initial => true
    state :submitted
    state :succeeded
    state :cancelled

    event :submit do
      transitions :from => :draft, :to => :submitted, :after => :set_request_date
    end
    event :close do
      transitions :from => :submitted, :to => :succeeded, :guard => :closeable?
    end
    event :cancel do
      transitions :from => :submitted, :to => :cancelled
    end
  end

  def set_request_date
    self.request_date = Time.current
  end

  def temporary?
    access_type == TEMPORARY
  end

  def duration
    return nil if !temporary?
    (end_date - start_date).to_i
  end

  def approved_count
    approvals.where(approved: true).count
  end

  def rejected_count
    approvals.where(approved: false).count
  end

  def approval_status
    return 'none' if draft?
    return 'failed' if rejected_count > 0
    closeable? ? 'success' : 'on progress'
  end

  def editable?(user)
    return ((self.user == user) || user.is_admin || (collaborators.include? user)) &&
      !terminal_state? && !has_approver?(user)
  end

  def approver_ids=(approver_ids)
    self.approvals << AccessRequestApproval.setup_for_access_request(self, approver_ids)
  end

  def previous
    AccessRequest.where(["id > ?", id]).first
  end

  def next
    AccessRequest.where(["id < ?", id]).last
  end


  def associated_users
    (collaborators + approvals.collect(&:user)).to_a
  end

  def create_access_request_status
    return unless state_changed?
    status = statuses.new(:status => aasm_state, :reason => reason)
    unless status.valid?
      self.errors[:status] << status.errors.full_messages
      self.aasm_state = previous_state
      return false
    end
  end

  def state_changed?
    aasm_state != previous_state
  end

  def previous_state
    return changes['aasm_state'].first if changes.key?('aasm_state')
    aasm_state
  end

  def terminal_state?
    return cancelled? || succeeded?
  end

  def state_require_note?(state)
    states = [:cancel]
    states.include? state
  end

  def next_states
    return aasm.events(permitted: true).map(&:name)
  end

  def current_state
    return aasm.current_event
  end

  def closeable?
    self.approvals.count > 0  && self.approved_count == self.approvals.count
  end

  def has_approver?(user)
    AccessRequestApproval.where(access_request_id: id, user_id: user.id).any?
  end

  def is_associate?(user)
    stakeholders = [self.user] + collaborators + (approvals.map { |approval| approval.user })
    stakeholders.include? user
  end

  def is_approved?(user)
    AccessRequestApproval.where(access_request_id: id, user_id: user.id).first.approved
  end

  def actionable?(user)
    (user.is_admin || is_associate?(user)) && !draft?
  end

  comma do
    id
    user_id "User ID"
    request_type "Request Type"
    access_type "Access Type"
    start_date "Start date"
    end_date "End date"
    employee_name "Employee Name"
    employee_position "Employee Position"
    employee_email_address "Employee Email Address"
    employee_department "Employee Departmen"
    employee_phone "Employee Phone"
    employee_access "Employee Access"
    fingerprint_business_area "Fingerprint Business Area"
    fingerprint_business_operations "Fingerprint Business Operations"
    fingerprint_it_operations "Fingerprint IT Operations"
    fingerprint_server_room "Fingerprint Server Room"
    fingerprint_archive_room "Fingerprint Archive Room"
    fingerprint_engineering_area "Fingerprint Engineering Area"
    corporate_email "Corporate Email"
    internet_access "Internet Access"
    slack_access "Slack Access"
    admin_tools "Admin Tools"
    vpn_access "VPN Access"
    github_gitlab "Github/Gitlab"
    exit_interview "Exit Interview"
    access_card "Access Card"
    parking_cards "Parking Cards"
    id_card "ID Card"
    name_card "Name Card"
    insurance_card "Insurance Card"
    cash_advance "Cash Advance"
    password_reset "Password Reset"
    user_identification "User Identification"
    asset_name "Asset Name"
    production_access "Production Access"
    production_user_id "Production User ID"
    production_asset "Production Asset"
    aasm_state "AASM state"
    request_date "Request Date"
    created_at "Created At"
    updated_at "Updated At"
    business_justification "Business Justification"
  end

  def self.relevant_access_requests(user)
    AccessRequest.where("user_id = #{user.id} OR id IN (
      #{AccessRequestApproval.where(user_id: user.id).select(:access_request_id).to_sql + " UNION " +
        user.collaborate_access_requests.select(:access_request_id).to_sql})").distinct
  end

  def self.create_for_new_registration_user(new_user, params, approver_user) 
    AccessRequest.transaction do
      access_request = new_user.AccessRequests.build(
        params.merge({
          request_type: DEFAULT_REQUEST_TYPE,
          access_type: DEFAULT_ACCESS_TYPE,
          employee_email_address: new_user.email
        })
      )
      approvers = Array.wrap([ approver_user.id ])
      access_request.approver_ids = approvers
      access_request.save
      access_request
    end
  end

end
