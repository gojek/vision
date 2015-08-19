class AddSolvingDurationToIncidentReport < ActiveRecord::Migration
  def change
    add_column :incident_reports, :solving_duration, :real
  end
end
