class AddHideToComment < ActiveRecord::Migration
  def change
    add_column :comments, :hide, :boolean, default: false
  end
end
