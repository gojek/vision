class AddEntitySourceToIncidentReport < ActiveRecord::Migration
  def change
    add_column :incident_reports, :entity_source, :string, default: 'Midtrans', null: false
  end
end
