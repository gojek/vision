class AddCabDetailsToCab < ActiveRecord::Migration[5.2]
  def change
    add_column :cabs, :room, :string
    add_column :cabs, :notes, :text
  end
end
