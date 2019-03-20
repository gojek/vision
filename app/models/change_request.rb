class ChangeRequest < ActiveRecord::Base
  include AASM
  include EntitySourceModule

  belongs_to :user
  attr_accessor :approver_ids

  acts_as_readable :on => :updated_at
  has_and_belongs_to_many :collaborators, join_table: :collaborators, class_name: :User
  has_and_belongs_to_many :testers, join_table: :testers, class_name: :User
  has_and_belongs_to_many :implementers, join_table: :implementers, class_name: :User
  has_and_belongs_to_many :associated_users, join_table: :change_requests_associated_users, class_name: :User
  has_many :change_request_statuses, -> {order('created_at asc')}, dependent: :destroy
  has_many :approvals, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :notifications, dependent: :destroy
  acts_as_taggable
  has_paper_trail class_name: 'ChangeRequestVersion', meta: { author_username: :user_name }
  SCOPE = %w(Major Minor)
  PRIORITY = %w(High Medium Low)
  
  validates :scope,
            inclusion: { in: SCOPE, message: '%{value} is not a valid scope' }
  validates :priority,
            inclusion: { in: PRIORITY, message: '%{value} is not a valid scope' }
  STATUS = %w(submitted deployed rollbacked cancelled succeeded failed draft)

  validates :change_summary, :priority,:change_requirement, :business_justification, :analysis, :solution, :impact, :scope, :design,
            :backup, :testing_procedure, :schedule_change_date, :planned_completion, :definition_of_success, :definition_of_failed, presence: true
  validates_inclusion_of :testing_environment_available, :in => [true, false]
  accepts_nested_attributes_for :implementers, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :testers, :allow_destroy => true
  accepts_nested_attributes_for :approvals, :allow_destroy => true
  validate :at_least_one_category
  validate :at_least_one_type
  validates :implementers, presence: true
  validates :approvals, presence: true
  validates :expected_downtime_in_minutes, numericality: { only_integer: true }, if: :downtime_expected?
  validate :deploy_date, :if => :schedule_change_date? && :planned_completion?
  validate :grace_period_date, :if => :grace_period_date_starts? && :grace_period_end

  after_save :set_associated_users

  def set_associated_users
    associated_users_array = Array.wrap([user_id])
    associated_users_array.concat(collaborators.collect(&:id).to_a)
    associated_users_array.concat(testers.collect(&:id).to_a)
    associated_users_array.concat(implementers.collect(&:id).to_a)
    associated_users_array.concat(approvals.collect(&:user_id).to_a)
    self.associated_user_ids = associated_users_array.uniq
  end

  searchable do
    text :change_summary, stored: true
    text :change_requirement, stored: true
    text :business_justification, stored: true
    text :note, stored: true
    text :os, stored: true
    text :db, stored: true
    text :net, stored: true
    text :other_dependency, stored: true
    text :analysis, stored: true
    text :solution, stored: true
    text :impact, stored: true
    text :design, stored: true
    text :backup, stored: true
    text :definition_of_success, stored: true
    text :definition_of_failed, stored: true
    text :testing_procedure, stored: true
    text :implementation_notes, stored: true
    text :grace_period_notes, stored: true
    time :created_at, stored: true
  end

  aasm do
    state :submitted
    state :deployed
    state :rollbacked
    state :cancelled
    state :succeeded
    state :failed
    state :draft, :initial => true

    event :submit do
      transitions :from => :draft, :to => :submitted
    end
    event :cancel do
      transitions :from => :submitted, :to => :cancelled
    end
    event :deploy do
      transitions :from => :submitted, :to => :deployed, :guard => :deployable?
    end
    event :close do
      transitions :from => :deployed, :to => :succeeded, :after => :set_closed_date
    end
    event :rollback do
      transitions :from => [:succeeded, :deployed], :to => :rollbacked, :after => :set_closed_date
    end
    event :fail do
      transitions :from => [:succeeded, :deployed], :to => :failed, :after => :set_closed_date
    end
  end

  comma do
    id 'Request id'
    __use__:entity_source
    change_summary 'Change summary'
    all_category 'Category'
    all_type 'Type'
    priority
    scope do |html| Sanitize.fragment(html) end
    change_requirement 'Change requirement' do |html| Sanitize.fragment(html) end
    business_justification 'Business justification' do |html| Sanitize.fragment(html) end
    aasm_state 'CR Status' do |status| status.humanize end
    approval_status 'Approval Status'
    created_at to_s: 'Request date'
    schedule_change_date to_s: 'Schedule change'
    planned_completion to_s: 'Planned completion'
    user name: 'Requestor'
    tag_list 'Tags' do |tag_list| tag_list.join(';') end
    approvals 'Approver' do |approvals| approvals.collect(&:user).collect(&:name).join(';') end
    testers do |testers| testers.collect(&:name).join(';') end
    implementers do |implementers| implementers.collect(&:name).join(';') end
  end

  def set_closed_date
    self.closed_date = Time.now
  end

  def at_least_one_category
    if [self.category_application, self.category_other, self.category_server, self.category_user_access,self.category_network_equipment].reject(&:blank?).size == 0
      errors[:base] << ("Please choose at least one category.")
    end
  end
  def tester_required
    if self.testing_environment_available && self.testers.size == 0
      errors[:base] << ("Testers can't be blank. ")
    end
  end

  def at_least_one_type
    if [self.type_security_update, self.type_install_uninstall, self.type_configuration_change, self.type_emergency_change,self.type_other].reject(&:blank?).size == 0
      errors[:base] << ("Please choose at least one type.")
    end
  end

  def no_implementers(attributes)
    attributes[:implementers_id]
  end

  def approval_status
    completed = self.approvers_count == self.approvals.count
    due = schedule_change_date.present? && Date.today > schedule_change_date.to_date
    if !completed && due
      status = 'failed'
    elsif !completed && !due
      status = 'on progress'
    else
      status = 'success'
    end
  end

  def approvers_count
    self.approvals.where(approve: true).count
  end

  def rejects_count
    self.approvals.where(approve: false).count
  end
   def deploy_date
    errors.add(:deploy_date, "is invalid.") unless schedule_change_date < planned_completion
  end

  def grace_period_date
    if !grace_period_starts.nil?
      if grace_period_starts > grace_period_end
        errors.add(:grace_period_time, "is invalid")
      end
    end
  end

  def deployable?
    self.approvals.where(approve: true).count == self.approvals.count
  end

  def previous_cr
     ChangeRequest.where(["id > ?", id]).first
  end

  def next_cr
    ChangeRequest.where(["id < ?", id]).last
  end

  def all_category
    type_array = []
    self.category_application ? type_array.push('Application') : nil
    self.category_network_equipment ? type_array.push('Network Equipment') : nil
    self.category_server ? type_array.push('Server') : nil
    self.category_user_access ? type_array.push('User Access') : nil
    self.category_other.blank? ? nil : type_array.push(self.category_other)
    type_array.join(', ')
  end

  def all_type
    category_array = []
    self.type_security_update ? category_array.push('Security Update') : nil
    self.type_install_uninstall ? category_array.push('Install Uninstall') : nil
    self.type_configuration_change ? category_array.push('Configuration Change') : nil
    self.type_emergency_change ? category_array.push('Emergency Change') : nil
    self.type_other.blank? ? nil : category_array.push(self.type_other)
    category_array.join(', ')
  end

  def lifetime
    if(closed_date?)
      s = closed_date - self.created_at
    else
      s = Time.now - self.created_at
    end
    dhms = [60,60,24].reduce([s]) { |m,o| m.unshift(m.shift.divmod(o)).flatten }
    result = dhms[0].to_s + " Days, " + dhms[1].to_s + " Hours, " + dhms[2].to_s + " minutes."
  end


  def approver_ids=(approver_ids)
    approvals = Approval.setup_for_change_request(self, approver_ids)
    self.approvals << approvals
  end

  def has_approver?(user)
    Approval.where(change_request_id: id, user_id: user.id).any?
  end

  def terminal_state?
    return self.cancelled? || self.failed? || self.rollbacked?
  end

  def state_require_note?(state)
    states = [:cancel, :fail, :rollback]
    states.include? state
  end

  def next_states
    return self.aasm.events(:permitted => true).map(&:name)
  end

  def current_state
    return self.aasm.current_event
  end

  def editable?(user)
    return (user == self.user || user.collaborate_change_requests.include?(self) ||
           user.is_admin || user.role == 'release_manager') &&
           !self.terminal_state? &&
           !self.has_approver?(user)
  end

  def deploy_delayed?
    ChangeRequestStatus.where(change_request_id: id, deploy_delayed: true).any?
  end

  def is_approved?(user)
    Approval.where(change_request_id: id, user_id: user.id).first.approve
  end

  def closed?
    closed_date.present?
  end

end
