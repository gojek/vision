class AddApprovalDateOnApprovalTable < ActiveRecord::Migration[5.2]
  def change
    add_column :approvers, :approval_date, :datetime
  end
end
