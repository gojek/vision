class AddNoteToChangeRequest < ActiveRecord::Migration[5.2]
  def change
    add_column :change_requests, :rollback_note, :text
    add_column :change_requests, :reject_note, :text
    add_column :change_requests, :close_note, :text
  end
end
