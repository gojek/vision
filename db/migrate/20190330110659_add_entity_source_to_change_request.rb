class AddEntitySourceToChangeRequest < ActiveRecord::Migration
  def change
  	add_column :change_requests, :entity_source, :string, default: 'Midtrans', null: false
  end
end
