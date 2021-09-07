class UpdateValueIncidentReportsRecoveredToAcknowledged < ActiveRecord::Migration[5.2]
  def up
    execute <<-SQL
      UPDATE incident_reports SET current_status = 'Acknowledged'
        WHERE current_status = 'Recovered';
    SQL
  end

  def down
    execute <<-SQL
      UPDATE incident_reports SET current_status = 'Recovered'
        WHERE current_status = 'Acknowledged';
    SQL
  end
end
