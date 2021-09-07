class AddReferenceToUserImplementer < ActiveRecord::Migration[5.2]
  def change
  	add_reference :implementers, :user, foreign_key: :true, index: :true
  end
end
