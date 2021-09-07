class AddEntitySourceToChangeRequest < ActiveRecord::Migration[5.2]
  def change
  	add_column :change_requests, :entity_source, :string, default: 'Midtrans', null: false
  end
end
