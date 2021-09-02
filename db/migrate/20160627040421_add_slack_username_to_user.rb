class AddSlackUsernameToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :slack_username, :string
  end
end
