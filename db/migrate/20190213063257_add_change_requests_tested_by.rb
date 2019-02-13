class AddChangeRequestsTestedBy < ActiveRecord::Migration
  def change
    add_column :change_requests, :tested_by_qa, :boolean, default: false
    add_column :change_requests, :tested_by_dev, :boolean, default: false
    add_column :change_requests, :tested_by_dev_ops, :boolean, default: false
  end
end
