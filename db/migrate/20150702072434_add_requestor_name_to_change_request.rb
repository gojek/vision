class AddRequestorNameToChangeRequest < ActiveRecord::Migration[5.2]
  def change
    add_column :change_requests, :requestor_name, :string
  end
end
