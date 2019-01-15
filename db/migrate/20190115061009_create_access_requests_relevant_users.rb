class CreateAccessRequestsRelevantUsers < ActiveRecord::Migration
  def change
    create_table :access_requests_associated_users do |t|
      t.references :user, index: true, foreign_key: true
      t.references :access_request, index: true, foreign_key: true
    end
  end
end
