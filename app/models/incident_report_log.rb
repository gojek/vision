class IncidentReportLog < ApplicationRecord
  belongs_to :incident_report
  belongs_to :user
  validates :user, :reason, presence: true
end
