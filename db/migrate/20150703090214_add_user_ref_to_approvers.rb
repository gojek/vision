class AddUserRefToApprovers < ActiveRecord::Migration[5.2]
  def change
    add_reference :approvers, :user, index: true, foreign_key: true
  end
end
