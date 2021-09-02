class ObjectChange < ActiveRecord::Migration[5.2]
  def change
    add_column :change_request_versions, :object_changes, :text
  end
end

