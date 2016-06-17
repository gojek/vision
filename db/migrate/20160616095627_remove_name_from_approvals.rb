class RemoveNameFromApprovals < ActiveRecord::Migration
  def change
    remove_column :approvals, :name
    remove_column :approvals, :position
  end
end
