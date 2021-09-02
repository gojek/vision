class AddAasmStateToChangeRequest < ActiveRecord::Migration[5.2]
  def change
    add_column :change_requests, :aasm_state, :string
  end
end
