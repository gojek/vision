# a model representating incident report document
class IncidentReport < ActiveRecord::Base
  belongs_to :user
  has_paper_trail class_name: 'IncidentReportVersion',
                  meta: { author_username: :user_name }
  acts_as_taggable
  CURRENT_STATUS = %w(Recovered Ongoing)
  MEASURER_STATUS = %w(Implemented Development)
  SOURCE = %w(Internal External)
  RECURRENCE_CONCERN = %w(Low Medium High)
  validates :service_impact, :problem_details, :how_detected, :occurrence_time,
            :detection_time, :recovery_time, :loss_related, :occurred_reason,
            :overlooked_reason, :recovery_action, :prevent_action,
            presence: true
  validates :current_status, presence: true,
            inclusion: { in: CURRENT_STATUS,
                        message: '%{ value } is not a valid status' }
  validates :measurer_status, presence: true,
            inclusion: { in: MEASURER_STATUS, message: '%{ value } is not a valid status' }
  validates :source, presence: true,
            inclusion: { in: SOURCE, message: '%{ value } is not a valid source'}
  validates :recurrence_concern, presence: true,
            inclusion: { in: RECURRENCE_CONCERN, message: '%{ value } is not a valid value' }
  validates :rank, presence: true, inclusion: { in: 1..5, message: '%{ value } is not a valid value' }
  validate  :validate_recovery_duration
  validate  :validate_resolution_duration

  def user_name
    user ? user.name : ''
  end

  def set_recovery_duration
    self.recovery_duration = (self.recovery_time-self.occurrence_time)/60
  end

  def set_resolution_duration
    self.resolution_duration = (self.resolved_time - self.occurrence_time)/60
  end

  def validate_recovery_duration
    errors.add("Recovery Duration", "is invalid.") unless  recovery_time > occurrence_time
  end

  def validate_resolution_duration
    errors.add("Recovery Duration", "is invalid.") unless  resolved_time > occurrence_time
  end

end
