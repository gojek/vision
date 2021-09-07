class AddBusinessJustificationToAccessRequests < ActiveRecord::Migration[5.2]
  def change
    add_column :access_requests, :business_justification, :string
  end
end
