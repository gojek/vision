class AddMetabaseToAccessRequests < ActiveRecord::Migration
  def change
    add_column :access_requests, :metabase, :boolean, default: false
  end
end
