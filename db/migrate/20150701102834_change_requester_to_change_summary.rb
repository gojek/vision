class ChangeRequesterToChangeSummary < ActiveRecord::Migration[5.2]
  def change
  	rename_column :change_requests, :requestor_desc, :change_summary
  end
end
