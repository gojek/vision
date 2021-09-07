class AddRejectReasonToApprover < ActiveRecord::Migration[5.2]
  def change
    add_column :approvers, :reject_reason, :text
  end
end
