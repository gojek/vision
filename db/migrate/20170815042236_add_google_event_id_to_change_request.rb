class AddGoogleEventIdToChangeRequest < ActiveRecord::Migration
  def change
  	add_column :change_requests, :google_event_id, :string, default: nil, null: true
  end
end
