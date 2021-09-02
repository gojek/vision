class AddVisionAccessOnAccessRequest < ActiveRecord::Migration[5.2]
  def change
    add_column :access_requests, :vision_access, :boolean, default: false
  end
end
