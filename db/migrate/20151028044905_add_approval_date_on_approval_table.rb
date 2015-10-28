class AddApprovalDateOnApprovalTable < ActiveRecord::Migration
  def change
    add_column :approvers, :approval_date, :datetime
  end
end
