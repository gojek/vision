class AddExpectedToIncidentReport < ActiveRecord::Migration
  def change
  	add_column :incident_reports, :expected, :boolean, default: false
  end
end
