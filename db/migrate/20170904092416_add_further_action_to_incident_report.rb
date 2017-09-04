class AddFurtherActionToIncidentReport < ActiveRecord::Migration
  def change
    add_column :incident_reports, :has_further_action, :boolean, default: false
    add_column :incident_reports, :action_item, :text
    add_column :incident_reports, :action_item_status, :string
    add_column :incident_reports, :action_item_done_time, :datetime, null: true
  end
end
