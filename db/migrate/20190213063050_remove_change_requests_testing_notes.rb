class RemoveChangeRequestsTestingNotes < ActiveRecord::Migration
  def change
    remove_column :change_requests, :testing_notes
  end
end
