class AddActionToChangeRequest < ActiveRecord::Migration
  def change
    add_column :change_requests, :action_item, :text
    add_column :change_requests, :action_item_status, :string
  end
end
