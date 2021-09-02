class CreateAccessRequestStatuses < ActiveRecord::Migration[5.2]
  def change
    create_table :access_request_statuses do |t|
      t.references :access_request, index: true, foreign_key: true

      t.string :status
      t.text :reason

      t.timestamps null: false
    end
  end
end
