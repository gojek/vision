class AddChangeRequestRefToChangeRequest < ActiveRecord::Migration
  def change
    add_reference :change_requests, :reference_cr, references: :change_requests, index: true
    add_foreign_key :change_requests, :change_requests, column: :reference_cr_id
  end
end
