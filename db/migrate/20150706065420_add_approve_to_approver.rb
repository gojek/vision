class AddApproveToApprover < ActiveRecord::Migration[5.2]
  def change
    add_column :approvers, :approve, :boolean
  end
end
