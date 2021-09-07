class AddEventIdToCab < ActiveRecord::Migration[5.2]
  def change
    add_column :cabs, :event_id, :string
  end
end
