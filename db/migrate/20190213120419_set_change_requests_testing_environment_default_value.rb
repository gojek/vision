class SetChangeRequestsTestingEnvironmentDefaultValue < ActiveRecord::Migration[5.2]
  def change
    change_column :change_requests, :testing_environment_available, :boolean, default: true
  end
end
