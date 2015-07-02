class RemoveRestoreFromChangeRequest < ActiveRecord::Migration
  def change
  	remove_column :change_requests, :restore, :text
  end
end
