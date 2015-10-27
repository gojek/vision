class AddEventIdToCab < ActiveRecord::Migration
  def change
    add_column :cabs, :event_id, :string
  end
end
