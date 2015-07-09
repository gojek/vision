class ChangeRequest < ActiveRecord::Base
  belongs_to :user
  has_many :testers
  has_many :implementers
  has_many :cabs
  has_many :approvers
  has_many :comments
  acts_as_taggable
  has_paper_trail class_name: 'ChangeRequestVersion'
  SCOPE = %w(Major Minor)
  STATUS = %w(Submitted Scheduled Rejected Deployed Rollback Cancelled Closed)
  #validates :requestor_name, :requestor_position, :change_summary, :priority, :category, :cr_type, :change_requirement, :business_justification, :note, :analysis, :solution, :impact, :scope, :design,
           # :backup, :testing_environment_avaible, :testing_procedure, :testing_notes, :schedule_change_date, :planned_completion, :grace_period_starts, :grace_period_end, :implementation_notes, :grace_period_notes,
          #  :user_id, :net, :db, :os, presence: true
  accepts_nested_attributes_for :implementers, :allow_destroy => true
  accepts_nested_attributes_for :testers, :allow_destroy => true
  accepts_nested_attributes_for :cabs, :allow_destroy => true
  accepts_nested_attributes_for :approvers, :allow_destroy => true
  #validates :change_summary, :priority, :category, :cr_type, :change_requirement, :business_justification, :requestor_position, :requestor_name, presence: true
  def user_name
    user ? user.name : ''
  end

end

