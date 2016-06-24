class RenameApproversToApprovals < ActiveRecord::Migration
  def change
    rename_column :approvers, :reject_reason, :notes
    rename_table :approvers, :approvals
  end
end
