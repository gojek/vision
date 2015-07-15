class AddCabDetailsToCab < ActiveRecord::Migration
  def change
    add_column :cabs, :room, :string
    add_column :cabs, :notes, :text
  end
end
