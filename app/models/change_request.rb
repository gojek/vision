class ChangeRequest < ActiveRecord::Base
  include AASM
  belongs_to :user
  has_many :testers, dependent: :destroy
  has_many :implementers, dependent: :destroy
  has_many :change_request_statuses, dependent: :destroy
  has_many :approvers, dependent: :destroy
  has_many :comments, dependent: :destroy
  belongs_to :cab
  scope :cab_free, -> {where(cab_id: nil)}
  acts_as_taggable
  has_paper_trail class_name: 'ChangeRequestVersion'
  SCOPE = %w(Major Minor)
  validates :scope,
            inclusion: { in: SCOPE, message: '%{ value } is not a valid scope' }
  STATUS = %w(submitted scheduled rollbacked cancelled rejected deployed closed)
  #validates :requestor_name, :requestor_position, :change_summary, :priority, :category, :cr_type, :change_requirement, :business_justification, :note, :analysis, :solution, :impact, :scope, :design,
           # :backup, :testing_environment_avaible, :testing_procedure, :testing_notes, :schedule_change_date, :planned_completion, :grace_period_starts, :grace_period_end, :implementation_notes, :grace_period_notes,
          #  :user_id, :net, :db, :os, presence: true
  accepts_nested_attributes_for :implementers, :allow_destroy => true
  accepts_nested_attributes_for :testers, :allow_destroy => true
  accepts_nested_attributes_for :approvers, :allow_destroy => true
  #validates :change_summary, :priority, :category, :cr_type, :change_requirement, :business_justification, :requestor_position, :requestor_name, presence: true
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
      transitions :from => [:submitted, :rejected, :deployed, :rollbacked, :cancelled, :scheduled], :to => :closed
    end
    event :submit do 
      transitions :form => :cancelled, :to => :submitted 
    end
  end
  
  def approvers_count
    self.approvers.where(approve: true).count 
  end
  
  def approvable?
    self.approvers.where(approve: true).count >= CONFIG[:minimum_approval]
  end

  def all_type
    type_array = []
    self.category_application ? type_array.push('Application') : nil
    self.category_network_equipment ? type_array.push('Network Equipment') : nil
    self.category_server ? type_array.push('Server') : nil
    self.category_user_access ? type_array.push('User Access') : nil
    self.category_other.blank? ? nil : type_array.push(self.category_other)
    type_array.join(', ')
  end

  def all_category
    category_array = []
    self.type_security_update ? category_array.push('Security Update') : nil
    self.type_install_uninstall ? category_array.push('Install Uninstall') : nil
    self.type_configuration_change ? category_array.push('Configuration Change') : nil
    self.type_emergency_change ? category_array.push('Emergency Change') : nil
    self.type_other.blank? ? nil : category_array.push(self.type_other)
    category_array.join(', ')
  end

end

