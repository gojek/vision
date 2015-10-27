class AddRejectReasonToApprover < ActiveRecord::Migration
  def change
    add_column :approvers, :reject_reason, :text
  end
end
