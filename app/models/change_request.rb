class ChangeRequest < ActiveRecord::Base
  include AASM
  belongs_to :user
  has_many :testers
  has_many :implementers
  has_many :change_request_statuses
  has_many :approvers
  has_many :comments
  belongs_to :cab
  scope :cab_free, -> {where(cab_id: nil)}
  acts_as_taggable
  has_paper_trail class_name: 'ChangeRequestVersion'
  SCOPE = %w(Major Minor)
  STATUS = %w(submitted scheduled rejected deployed rollback cancelled closed)
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
end

