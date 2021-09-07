class CreateChangeRequestsRelevantUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :change_requests_associated_users do |t|
    	t.references :user, index: true, foreign_key: true
    	t.references :change_request, index: true, foreign_key: true
    end
  end
end
