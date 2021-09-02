class AddSolutionsDashboardToAccessRequests < ActiveRecord::Migration[5.2]
  def change
    add_column :access_requests, :solutions_dashboard, :boolean, default: false
  end
end
