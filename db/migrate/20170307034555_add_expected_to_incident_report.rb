class AddExpectedToIncidentReport < ActiveRecord::Migration[5.2]
  def change
  	add_column :incident_reports, :expected, :boolean, default: false
  end
end
