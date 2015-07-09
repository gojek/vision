class ObjectChange < ActiveRecord::Migration
  def change
    add_column :change_request_versions, :object_changes, :text
  end
end

