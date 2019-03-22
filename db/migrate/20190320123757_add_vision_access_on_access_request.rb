class AddVisionAccessOnAccessRequest < ActiveRecord::Migration
  def change
    add_column :access_requests, :vision_access, :boolean, default: false
  end
end
