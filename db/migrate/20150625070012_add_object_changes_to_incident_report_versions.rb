class AddObjectChangesToIncidentReportVersions < ActiveRecord::Migration
  def change
    add_column :incident_report_versions, :object_changes, :text
  end
end
