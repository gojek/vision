oclass AddDowntimeToCr < ActiveRecord::Migration
  def change
    add_column :change_requests, :downtime_expected, :boolean, default: false
    add_column :change_requests, :expected_downtime_in_minutes, :integer, null: true
  end
end
