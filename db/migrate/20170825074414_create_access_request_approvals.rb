class CreateAccessRequestApprovals < ActiveRecord::Migration
  def change
    create_table :access_request_approvals do |t|
      t.references :user, index: true, foreign_key: true
      t.references :access_request, index: true, foreign_key: true

      t.boolean :approved

      t.timestamps null: false
    end
  end
end
