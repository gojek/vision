class AddAasmStateToChangeRequest < ActiveRecord::Migration
  def change
    add_column :change_requests, :aasm_state, :string
  end
end
