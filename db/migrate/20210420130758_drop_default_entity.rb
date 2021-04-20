class DropDefaultEntity < ActiveRecord::Migration
  def change
    change_column_default(:change_requests, :entity_source, nil)
    change_column_default(:access_requests, :entity_source, nil)
    change_column_default(:incident_reports, :entity_source, nil)
  end
end
