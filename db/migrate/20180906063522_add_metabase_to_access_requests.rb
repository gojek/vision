class AddMetabaseToAccessRequests < ActiveRecord::Migration[5.2]
  def change
    add_column :access_requests, :metabase, :boolean, default: false
  end
end
