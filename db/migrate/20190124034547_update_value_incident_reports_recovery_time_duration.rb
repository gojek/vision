class UpdateValueIncidentReportsRecoveryTimeDuration < ActiveRecord::Migration
  def change
    execute <<-SQL
      UPDATE incident_reports 
        SET recovery_duration = EXTRACT(epoch FROM resolved_time) - EXTRACT(epoch FROM detection_time);
    SQL
  end
end
