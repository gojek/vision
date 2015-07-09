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
  def schedule
    if submitted?
      self.status = 'Scheduled'
      self.save
    end
  end
  def deploy
   if schedulled?
      self.status = 'Deployed'
      self.save
    end
  end
  def rollback
  end
  def cancel
    if schedulled?
      self.status = 'Cancelled'
      self.save
    end
  end
  def close
    self.status = 'Closed'
    self.save
  end  
  def final_reject
    if submitted?
      self.status = 'Reject'
      self.save
    end
  end
  def submit
    if cancelled?
      self.status = 'Submitted'
      self.save
    end
  end
  def submitted?
    self.status == 'Submitted'
  end
  def schedulled?
    self.status == 'Scheduled'
  end
  def closed?
    self.status == 'Closed'
  end
  def rejected?
    self.status == 'Rejected'
  end
  def deployed?
    self.status == 'Deployed'
  end
  def rollback?
    self.status == 'Rollback'
  end
  def cancelled?
    self.status == "Cancelled"
  end
  def closed?
    self.status == 'Closed'
  end
end

