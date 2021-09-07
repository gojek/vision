class CreateIncidentReportLog < ActiveRecord::Migration[5.2]
  def change
    create_table :incident_report_logs do |t|
      t.references :incident_report, index: true, foreign_key: true
      t.references :user, index: true, foreign_key: true

      t.text :reason

      t.timestamps null: false
      
    end
  end
end
