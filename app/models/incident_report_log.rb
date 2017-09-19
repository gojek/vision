class IncidentReportLog < ActiveRecord::Base
  belongs_to :incident_report
  belongs_to :user
  validates :user, :reason, presence: true
end
