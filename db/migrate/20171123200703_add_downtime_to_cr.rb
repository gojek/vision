class AddDowntimeToCr < ActiveRecord::Migration[5.2]
  def change
    add_column :change_requests, :downtime_expected, :boolean
    add_column :change_requests, :expected_downtime_in_minutes, :integer
  end
end
