class AddCancelNoteToChangeRequest < ActiveRecord::Migration[5.2]
  def change
    add_column :change_requests, :cancel_note, :text
  end
end
