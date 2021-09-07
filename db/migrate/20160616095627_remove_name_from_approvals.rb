class RemoveNameFromApprovals < ActiveRecord::Migration[5.2]
  def change
    remove_column :approvals, :name
    remove_column :approvals, :position
  end
end
