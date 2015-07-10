class CreateChangeRequestStatuses < ActiveRecord::Migration
  def change
    create_table :change_request_statuses do |t|
      t.string :status
      t.text :reason

      t.timestamps null: false
    end
  end
end
