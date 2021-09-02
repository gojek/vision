class AddStateToChangeRequest < ActiveRecord::Migration[5.2]
  def change
    add_column :change_requests, :state, :string
  end
end
