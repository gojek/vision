class AddObjectChangesToIncidentReportVersions < ActiveRecord::Migration[5.2]
  def change
    add_column :incident_report_versions, :object_changes, :text
  end
end
