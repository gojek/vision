class AddIsApprovedToUsers < ActiveRecord::Migration
  def change
    add_column :users, :is_approved, :Integer, :default => 1
  end
end
