class AddStatusToChangeRequest < ActiveRecord::Migration
  def change
    add_column :change_requests, :status, :string
  end
end
