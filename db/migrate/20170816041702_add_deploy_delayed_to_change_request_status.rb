class AddDeployDelayedToChangeRequestStatus < ActiveRecord::Migration[5.2]
  def change
  	add_column :change_request_statuses, :deploy_delayed, :boolean
  end
end
