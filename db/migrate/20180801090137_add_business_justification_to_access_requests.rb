class AddBusinessJustificationToAccessRequests < ActiveRecord::Migration
  def change
    add_column :access_requests, :business_justification, :string
  end
end
