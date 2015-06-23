class IncidentReport < ActiveRecord::Base
  validates :service_impact, :problem_details, :how_detected, :occurrence_time, :detection_time, :recovery_time, :integer, :loss_related, :occurred_reason, :overlooked_reason, :recovery_action, :prevent_action, :presence => true
  belongs_to :user
  validates :current_status, :presence=>true, inclusion: { in: CURRENT_STATUS, message: "%{value} is not a valid status"}
  validates :measurer_status, :presence=>true, inclusion: { in: MEASURER_STATUS, message: "%{value} is not a valid status"}
  validates :source, :presence=>true, inclusion: { in: SOURCE, message: "%{value} is not a valid source"}
  validates :recurrence_concern, :presence=>true, inclusion: { in: RECURRENCE_CONCERN, message: "%{value} is not a valid value"}
  validates :rank, :presence=>true, inclusion: { in: 1..5, message: "%{value} is not a valid value"}

  CURRENT_STATUS = %w(Recovered Ongoing)
  MEASURER_STATUS = %w(Implemented Development)
  SOURCE = %w(Internal External)
  RECURRENCE_CONCERN = %w(Low Medium High)

end
