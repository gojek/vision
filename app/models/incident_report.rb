# a model representating incident report document
class IncidentReport < ActiveRecord::Base
  include ActiveModel::Dirty
  
  belongs_to :user
  acts_as_readable :on => :updated_at
  has_paper_trail class_name: 'IncidentReportVersion',
                  meta: { author_username: :user_name }
  acts_as_taggable
  CURRENT_STATUS = %w(Ongoing Recovered Resolved)
  MEASURER_STATUS = %w(Implemented Development)
  SOURCE = %w(Internal External)
  RECURRENCE_CONCERN = %w(Low Medium High)
  has_many :notifications
  validates :service_impact, :problem_details, :how_detected, :occurrence_time,
            :detection_time, :loss_related, :occurred_reason,
            :overlooked_reason, :recovery_action, :prevent_action,
            presence: true
  validates :measurer_status, presence: true,
            inclusion: { in: MEASURER_STATUS, message: '%{ value } is not a valid status' }
  validates :source, presence: true,
            inclusion: { in: SOURCE, message: '%{ value } is not a valid source'}
  validates :recurrence_concern, presence: true,
            inclusion: { in: RECURRENCE_CONCERN, message: '%{ value } is not a valid value' }
  validates :rank, presence: true, inclusion: { in: 1..5, message: '%{ value } is not a valid value' }
  validate  :validate_recovery_time, :if => :recovery_time? 
  validate  :validate_resolution_time, :if => :resolved_time? 
  validate  :validate_detection_time, :if => :detection_time?

  def user_name
    user ? user.name : ''
  end

  def check_status
    self.current_status_changed?(from: nil, to: "Resolved") || self.current_status_changed?(from: "Recovered", to: "Resolved") || self.current_status_changed?(from: "Ongoing", to: "Resolved")
  end

  def set_recovery_duration
    self.recovery_duration = (self.recovery_time-self.occurrence_time)/60
  end

  def set_resolution_duration
    self.resolution_duration = (self.resolved_time - self.occurrence_time)/60
  end

  def validate_recovery_time
    errors.add("Recovery Time", "is invalid.") unless  recovery_time > occurrence_time && recovery_time > detection_time
  end

  def validate_resolution_time
    errors.add("Resolved Time", "is invalid.") unless  resolved_time > occurrence_time && resolved_time > detection_time 
  end
  def validate_detection_time
    errors.add("Detection Time", "is invalid") unless detection_time > occurrence_time
  end

  def set_current_status
    if !self.resolved_time.blank?
      self.current_status = "Resolved"
    elsif !self.recovery_time.blank?
      self.current_status = "Recovered"
    else
      self.current_status = "Ongoing"
    end
  end

  def previous
   IncidentReport.where("id > ?",id).first
  end

  def next
    IncidentReport.where("id < ?",id).last
  end

end
