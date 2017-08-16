class AddDeployDelayedToChangeRequestStatus < ActiveRecord::Migration
  def change
  	add_column :change_request_statuses, :deploy_delayed, :boolean
  end
end
