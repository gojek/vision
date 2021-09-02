class AddAccessRequestIdToNotifications < ActiveRecord::Migration[5.2]
  def change
    add_column :notifications, :access_request_id, :integer
  end
end
