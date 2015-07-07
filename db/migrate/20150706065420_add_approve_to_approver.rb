class AddApproveToApprover < ActiveRecord::Migration
  def change
    add_column :approvers, :approve, :boolean
  end
end
