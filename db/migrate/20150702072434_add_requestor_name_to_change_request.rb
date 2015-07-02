class AddRequestorNameToChangeRequest < ActiveRecord::Migration
  def change
    add_column :change_requests, :requestor_name, :string
  end
end
