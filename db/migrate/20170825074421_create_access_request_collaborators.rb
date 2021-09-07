class CreateAccessRequestCollaborators < ActiveRecord::Migration[5.2]
  def change
    create_table :access_request_collaborators do |t|
      t.references :user, index: true, foreign_key: true
      t.references :access_request, index: true, foreign_key: true
    end
  end
end
