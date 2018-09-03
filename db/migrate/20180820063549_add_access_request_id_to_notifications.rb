class AddAccessRequestIdToNotifications < ActiveRecord::Migration
  def change
    add_column :notifications, :access_request_id, :integer
  end
end
