class AddOtherDepedencyToChangeRequest < ActiveRecord::Migration[5.2]
  def change
    add_column :change_requests, :other_dependency, :text
  end
end
