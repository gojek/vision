class RemoveRestoreFromChangeRequest < ActiveRecord::Migration[5.2]
  def change
  	remove_column :change_requests, :restore, :text
  end
end
