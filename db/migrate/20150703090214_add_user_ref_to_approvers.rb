class AddUserRefToApprovers < ActiveRecord::Migration
  def change
    add_reference :approvers, :user, index: true, foreign_key: true
  end
end
