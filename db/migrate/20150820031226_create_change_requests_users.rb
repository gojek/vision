class CreateChangeRequestsUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :change_requests_users, id: false do |t|
    	t.belongs_to :user, index: true
    	t.belongs_to :change_request, index: true
    end
  end
end
