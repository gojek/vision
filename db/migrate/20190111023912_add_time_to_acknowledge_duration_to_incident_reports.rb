class AddTimeToAcknowledgeDurationToIncidentReports < ActiveRecord::Migration
  def change
  	change_table :incident_reports do |t|
  		t.column :time_to_acknowledge_duration, :integer
  	end
  end
end
