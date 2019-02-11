class AddSolutionsDashboardToAccessRequests < ActiveRecord::Migration
  def change
    add_column :access_requests, :solutions_dashboard, :boolean, default: false
  end
end
