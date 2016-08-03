class RenameUserChangeRequestToCollaborator < ActiveRecord::Migration
  def change
    rename_table :change_requests_users, :collaborators
  end
end
