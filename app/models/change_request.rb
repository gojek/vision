class ChangeRequest < ActiveRecord::Base
  include AASM
  belongs_to :user
  acts_as_readable :on => :updated_at
  has_and_belongs_to_many :associated_users, join_table: :change_requests_associated_users, :class_name =>'User'
  has_and_belongs_to_many :collaborators, join_table: :collaborators, :class_name =>'User'
  has_and_belongs_to_many :testers, join_table: :testers, class_name: :User
  has_and_belongs_to_many :implementers, join_table: :implementers, class_name: :User
  has_many :change_request_statuses, -> {order('created_at asc')}, dependent: :destroy
  has_many :approvals, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :notifications, dependent: :destroy
  acts_as_taggable
  has_paper_trail class_name: 'ChangeRequestVersion', meta: { author_username: :user_name }
  SCOPE = %w(Major Minor)
  PRIORITY = %w(Critical Urgent High Normal Low)
  validates :scope,
            inclusion: { in: SCOPE, message: '%{value} is not a valid scope' }
  validates :priority,
            inclusion: { in: PRIORITY, message: '%{value} is not a valid scope' }
  STATUS = %w(submitted scheduled rollbacked cancelled rejected deployed closed)

  validates :change_summary, :priority,:change_requirement, :business_justification, :analysis, :solution, :impact, :scope, :design,
            :backup, :testing_procedure, :testing_notes, :schedule_change_date, :planned_completion, :definition_of_success, :definition_of_failed, presence: true
  validates_inclusion_of :testing_environment_available, :in => [true, false]
  accepts_nested_attributes_for :implementers, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :testers, :allow_destroy => true
  accepts_nested_attributes_for :approvals, :allow_destroy => true
  validate :at_least_one_category
  validate :at_least_one_type
  validates :implementers, presence: true
  validates :testers, presence: true
  validates :approvals, presence: true
  validate :deploy_date, :if => :schedule_change_date? && :planned_completion?
  validate :grace_period_date, :if => :grace_period_date_starts? && :grace_period_end

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
    text :testing_notes, stored: true
    text :implementation_notes, stored: true
    text :grace_period_notes, stored: true
    time :created_at, stored: true
  end

  aasm do
    state :submitted
    state :scheduled
    state :deployed
    state :rollbacked
    state :cancelled
    state :closed
    state :rejected
    state :draft, :initial => true
    event :schedule do
      transitions :from => :submitted, :to => :scheduled, :guard => :approvable?
    end
    event :reject do
      transitions :from => :submitted, :to => :rejected
    end
    event :deploy do
      transitions :from => :scheduled, :to => :deployed
    end
    event :rollback do
      transitions :from => [:scheduled, :deployed], :to => :rollbacked
    end
    event :cancel do
      transitions :from => :scheduled, :to => :cancelled
    end
    event :close do
      transitions :from => [:submitted, :rejected, :rollbacked, :cancelled, :scheduled], :to => :closed, after: :failed_change_request
      transitions :from => :deployed, :to => :closed, after: :success_change_request
    end
    event :submit do
      transitions :form => [:draft, :cancelled], :to => :submitted
    end
  end

  comma do
    id 'id'
    change_summary 'change summary'
    all_category 'category'
    all_type 'type'
    priority
    user name: 'requestor'
    tag_list 'tags' do |tag_list| tag_list.join(';') end
    collaborators do |collaborators| collaborators.collect(&:name).join(';') end
    approvals 'approvers' do |approvals| approvals.collect(&:user).collect(&:name).join(';') end
    change_requirement 'change requirement'
    business_justification 'business justification'
    note
    os 'operating system dependency'
    db 'database dependency'
    net 'network dependency'
    other_dependency 'other dependency'
    analysis
    solution
    impact
    scope
    design
    backup
    definition_of_success 'definition of success'
    definition_of_failed 'definition of failed'
    testing_environment_available to_s: 'testing environment available'
    testing_procedure 'testing procedure'
    testing_notes 'testing notes'
    testers do |testers| testers.collect(&:name).join(';') end
    schedule_change_date to_s: 'schedule change date'
    planned_completion to_s: 'planned completion'
    implementation_notes to_s: 'implementation notes'
    grace_period_starts to_s: 'grace period starts'
    grace_period_end to_s: 'grace period end'
    grace_period_notes to_s: 'grace period notes'
    implementers do |implementers| implementers.collect(&:name).join(';') end
  end

  def failed_change_request
    self.status = 'failed'
    self.closed_date = Time.now
  end

  def success_change_request
    self.status = 'success'
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

  def approvable?
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

  def set_approvers(approver_id_list)
    self.approvals.delete_all
    approver_id_list.each do |approver_id|
      approver = User.find(approver_id)
      approval = Approval.create(user: approver)
      self.approvals << approval
    end
  end

  def update_approvers(approver_id_list)
    current_approver_ids = Approval.where(change_request_id: self.id).pluck(:user_id)
    approver_id_list.map! {|id| id.to_i}
    deleted_approver_ids = current_approver_ids - approver_id_list
    if deleted_approver_ids.present?
      Approval.where(change_request_id: self.id).where(user_id: deleted_approver_ids).destroy_all
    end
    approver_id_list.each do |approver_id|
      app = Approval.where(user_id: approver_id).where(change_request_id: self.id).first
      if (!app.present?)
        approver = User.find(approver_id)
        new_approval = Approval.create(user: User.find(approver_id))
        self.approvals << new_approval
      end
    end
  end

  def set_implementers(implementer_id_list)
    self.implementers = []
    implementer_id_list.each do |implementer_id|
      self.implementers << User.find(implementer_id)
    end
  end

  def set_testers(tester_id_list)
    self.testers = []
    tester_id_list.each do |tester_id|
      self.testers << User.find(tester_id)
    end
  end

  def set_collaborators(collaborator_id_list)
    self.collaborators = []
    collaborator_id_list.each do |collaborator_id|
      self.collaborators << User.find(collaborator_id)
    end
  end

  def has_approver?(user)
    Approval.where(change_request_id: id, user_id: user.id).any?
  end

end
