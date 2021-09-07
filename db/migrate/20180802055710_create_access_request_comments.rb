class CreateAccessRequestComments < ActiveRecord::Migration[5.2]
  def change
    create_table :access_request_comments do |t|
      t.text     :body
      t.integer  :access_request_id
      t.integer  :user_id
      t.datetime :created_at,                        null: false
      t.datetime :updated_at,                        null: false
      t.boolean  :hide,              default: false
      t.timestamps null: false
    end
  end
end
