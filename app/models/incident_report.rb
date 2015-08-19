# a model representating incident report document
class IncidentReport < ActiveRecord::Base
  belongs_to :user
  has_paper_trail class_name: 'IncidentReportVersion',
                  meta: { author_username: :user_name }
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

  def user_name
    user ? user.name : ''
  end

  def set_solving_duration
    self.solving_duration = (self.recovery_time-self.detection_time)/60
  end


end
