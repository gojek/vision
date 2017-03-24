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

  has_many :notifications, dependent: :destroy
  validates :service_impact, :expected, :problem_details, :how_detected, :occurrence_time,
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

  # recovery and resolve may be the same, but it does not necessarily to be like that
  # recovery is temporary solution, resolved is life-time solution
  validate  :validate_recovery_time
  validate  :validate_resolution_time, if: :resolved_time?
  validate  :validate_detection_time

  searchable do
    text :service_impact, stored: true
    text :problem_details, stored: true
    text :how_detected, stored: true
    text :loss_related, stored: true
    text :occurred_reason, stored: true
    text :overlooked_reason, stored: true
    text :recovery_action, stored: true
    text :prevent_action, stored: true
    time :created_at, stored: true
  end

  comma do
    id     
    service_impact 'service impact'     
    problem_details 'problem details'     
    current_status 'current status'     
    rank     
    measurer_status 'measurer status'     
    recurrence_concern 'recurrence concern'     
    occurrence_time to_s: 'occurrence time'     
    detection_time to_s: 'detection time'     
    recovery_time to_s: 'recovery time'     
    recovery_duration to_s: 'recovery duration'     
    resolved_time 'resolved time'     
    how_detected 'how was problem detected'     
    loss_related 'loss related issue'
  end

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
    if occurrence_time.nil? ||
        recovery_time.nil? ||
        detection_time.nil? ||
        !(recovery_time > occurrence_time && recovery_time > detection_time)
      errors.add(:recovery_time, "is invalid")
    end
  end

  def validate_resolution_time
    if resolved_time.nil? || occurrence_time.nil? || detection_time.nil? ||
        !(resolved_time > occurrence_time && resolved_time > detection_time)
      errors.add(:resolved_time, "is invalid")
    end
  end

  def validate_detection_time
    if occurrence_time.nil? || detection_time.nil? || (detection_time < occurrence_time)
      errors.add(:detection_time, "is invalid")
    end
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
