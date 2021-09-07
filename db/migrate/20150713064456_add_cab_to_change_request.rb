class AddCabToChangeRequest < ActiveRecord::Migration[5.2]
  def change
    add_reference :change_requests, :cab, index: true, foreign_key: true
  end
end
