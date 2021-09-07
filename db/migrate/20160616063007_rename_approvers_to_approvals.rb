class RenameApproversToApprovals < ActiveRecord::Migration[5.2]
  def change
    rename_column :approvers, :reject_reason, :notes
    rename_table :approvers, :approvals
  end
end
