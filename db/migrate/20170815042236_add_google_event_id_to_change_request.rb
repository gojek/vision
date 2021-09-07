class AddGoogleEventIdToChangeRequest < ActiveRecord::Migration[5.2]
  def change
  	add_column :change_requests, :google_event_id, :string, default: nil, null: true
  end
end
