class ChangeRequesterToChangeSummary < ActiveRecord::Migration
  def change
  	rename_column :change_requests, :requestor_desc, :change_summary
  end
end
