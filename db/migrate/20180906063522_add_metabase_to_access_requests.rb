class AddMetabaseToAccessRequests < ActiveRecord::Migration
  def change
    add_column :access_requests, :metabase, :boolean
  end
end
