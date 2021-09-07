class CreateIncidentReports < ActiveRecord::Migration[5.2]
  def change
    create_table :incident_reports do |t|
      t.string :service_impact
      t.text :problem_details
      t.string :how_detected
      t.datetime :occurrence_time
      t.datetime :detection_time
      t.datetime :recovery_time
      t.string :source
      t.integer :rank
      t.string :loss_related
      t.text :occurred_reason
      t.text :overlooked_reason
      t.text :recovery_action
      t.text :prevent_action
      t.string :recurrence_concern
      t.string :current_status
      t.string :measurer_status
      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
