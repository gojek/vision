class AddEntitySourceToChangeRequest < ActiveRecord::Migration[5.2]
  def change
  	add_column :change_requests, :entity_source, :string, default: 'engineering', null: false
  end
end
