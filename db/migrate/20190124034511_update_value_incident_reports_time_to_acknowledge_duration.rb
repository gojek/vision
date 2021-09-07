class UpdateValueIncidentReportsTimeToAcknowledgeDuration < ActiveRecord::Migration[5.2]
  def change
    execute <<-SQL
      UPDATE incident_reports 
        SET time_to_acknowledge_duration = (EXTRACT(epoch FROM acknowledge_time) - EXTRACT(epoch FROM detection_time))/60;
    SQL
  end
end
