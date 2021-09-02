class AddResolutionTimeRecovertyTimeToIncidentReport < ActiveRecord::Migration[5.2]
  def change
    add_column :incident_reports, :resolved_time, :datetime
    add_column :incident_reports, :resolution_duration, :decimal
    add_column :incident_reports, :recovery_duration, :decimal
  end
end
