class AddHideToComment < ActiveRecord::Migration[5.2]
  def change
    add_column :comments, :hide, :boolean, default: false
  end
end
