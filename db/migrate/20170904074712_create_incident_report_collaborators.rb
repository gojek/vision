class CreateIncidentReportCollaborators < ActiveRecord::Migration[5.2]
  def change
    create_table :incident_report_collaborators do |t|
      t.references :user, index: true, foreign_key: true
      t.references :incident_report, index: true, foreign_key: true
    end
  end
end
