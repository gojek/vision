class AddReferenceToUserImplementer < ActiveRecord::Migration
  def change
  	add_reference :implementers, :user, foreign_key: :true, index: :true
  end
end
