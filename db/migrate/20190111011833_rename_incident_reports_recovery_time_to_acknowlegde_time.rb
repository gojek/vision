class RenameIncidentReportsRecoveryTimeToAcknowlegdeTime < ActiveRecord::Migration[5.2]
  def change
    change_table :incident_reports do |t|
      t.rename :recovery_time, :acknowledge_time
    end
  end
end
