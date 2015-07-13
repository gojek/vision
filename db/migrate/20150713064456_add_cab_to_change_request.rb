class AddCabToChangeRequest < ActiveRecord::Migration
  def change
    add_reference :change_requests, :cab, index: true, foreign_key: true
  end
end
