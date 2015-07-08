class AddPositionToUser < ActiveRecord::Migration
  def change
    add_column :users, :position, :string
  end
end
