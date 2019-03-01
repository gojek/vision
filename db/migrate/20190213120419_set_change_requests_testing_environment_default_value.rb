class SetChangeRequestsTestingEnvironmentDefaultValue < ActiveRecord::Migration
  def change
    change_column :change_requests, :testing_environment_available, :boolean, default: true
  end
end
