class AddIsApprovedToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :is_approved, :Integer, :default => 1
  end
end
