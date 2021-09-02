class RenameUserChangeRequestToCollaborator < ActiveRecord::Migration[5.2]
  def change
    rename_table :change_requests_users, :collaborators
  end
end
