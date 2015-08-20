class AddResolutionTimeRecovertyTimeToIncidentReport < ActiveRecord::Migration
  def change
    add_column :incident_reports, :resolved_time, :datetime
    add_column :incident_reports, :resolution_duration, :double
    add_column :incident_reports, :recovery_duration, :double
  end
end
