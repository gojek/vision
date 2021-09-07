class CreateAccessRequestApprovals < ActiveRecord::Migration[5.2]
  def change
    create_table :access_request_approvals do |t|
      t.references :user, index: true, foreign_key: true
      t.references :access_request, index: true, foreign_key: true

      t.boolean :approved
      t.text :notes

      t.timestamps null: false
    end
  end
end
