class DeviseUpdateGoogleUsers < ActiveRecord::Migration[5.2]
  def up
  	remove_column :users, :encrypted_password
  	remove_column :users, :reset_password_token
  	remove_column :users, :reset_password_sent_at
  	remove_column :users, :remember_created_at
  end

end
