class CreateNotifications < ActiveRecord::Migration[5.2]
  def change
    create_table :notifications do |t|
      t.references :user, index: true, foreign_key: true
      t.references :change_request, index: true, foreign_key: true
      t.references :incident_report, index: true, foreign_key: true
      t.boolean :read
      t.string :message

      t.timestamps null: false
    end
  end
end
