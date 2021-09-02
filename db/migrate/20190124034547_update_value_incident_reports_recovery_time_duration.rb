class UpdateValueIncidentReportsRecoveryTimeDuration < ActiveRecord::Migration[5.2]
  def change
    execute <<-SQL
      UPDATE incident_reports 
        SET recovery_duration = (EXTRACT(epoch FROM resolved_time) - EXTRACT(epoch FROM detection_time))/60;
    SQL
  end
end
