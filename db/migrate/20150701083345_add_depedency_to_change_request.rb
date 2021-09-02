class AddDepedencyToChangeRequest < ActiveRecord::Migration[5.2]
  def change
    add_column :change_requests, :net, :text
    add_column :change_requests, :db, :text
    add_column :change_requests, :os, :text
  end
end
