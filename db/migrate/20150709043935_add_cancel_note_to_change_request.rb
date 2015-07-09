class AddCancelNoteToChangeRequest < ActiveRecord::Migration
  def change
    add_column :change_requests, :cancel_note, :text
  end
end
