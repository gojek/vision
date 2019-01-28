class DropChangeRequestsAssociatedUsers < ActiveRecord::Migration
  def change
    drop_table :change_requests_associated_users
  end
end
