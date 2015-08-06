class AddRefreshTokenToUser < ActiveRecord::Migration
  def change
    add_column :users, :refresh_token, :string
    add_column :users, :expired_at, :datetime
  end
end
