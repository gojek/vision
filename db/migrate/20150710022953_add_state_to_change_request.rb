class AddStateToChangeRequest < ActiveRecord::Migration
  def change
    add_column :change_requests, :state, :string
  end
end
