class ChangeRequest < ActiveRecord::Base
  include AASM
  belongs_to :user
  acts_as_readable :on => :updated_at
  has_and_belongs_to_many :collaborators, :class_name =>'User'
  has_and_belongs_to_many :testers, join_table: :testers, class_name: :User
  has_and_belongs_to_many :implementers, join_table: :implementers, class_name: :User
  # has_many :implementers, dependent: :destroy
  # has_many :testers, dependent: :destroy
  has_many :change_request_statuses, dependent: :destroy
  has_many :approvals, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :notifications
  belongs_to :cab
  scope :cab_free, -> {where(cab_id: nil)}
  acts_as_taggable
  has_paper_trail class_name: 'ChangeRequestVersion'
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
  # validate :tester_required
  validates :testers, presence: true
  validates :approvals, presence: true
  validate :deploy_date, :if => :schedule_change_date? && :planned_completion?
  validate :grace_period_date, :if => :grace_period_date_starts? && :grace_period_end
  #validates :change_summary, :priority, :category, :cr_type, :change_requirement, :business_justification, :requestor_position, :requestor_name, presence: true

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
    state :submitted, :initial => true
    state :scheduled
    state :deployed
    state :rollbacked
    state :cancelled
    state :closed
    state :rejected
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
      transitions :form => :cancelled, :to => :submitted
    end
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
    errors.add(:grace_period_time, "is invalid") unless grace_period_starts < grace_period_end
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
  def arrange_google_calendar(current_user)
    attendees = []
    @participants = self.cab.participant.split(",")
    @participants.each do |participant|
      attendees.push({'email' => participant}) unless participant.blank?
    end

    event = {
      'summary' => self.change_summary,
      'location' => 'Veritrans',
      'start' => {
        'dateTime' => self.schedule_change_date.iso8601,
        'timeZone' => 'Asia/Jakarta',
      },
      'end' => {
        'dateTime' => self.planned_completion.iso8601,
        'timeZone' => 'Asia/Jakarta',
      },
      'attendees' => attendees
    }

    client = Google::APIClient.new
    client.authorization.access_token = current_user.fresh_token
    service = client.discovered_api('calendar', 'v3')
    results = client.execute!(
      :api_method => service.events.insert,
      :parameters => {
        :calendarId => 'primary', :sendNotifications => 'true'},
      :body_object => event)
    event = results.data

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


end
