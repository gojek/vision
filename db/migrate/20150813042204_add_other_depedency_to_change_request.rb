class AddOtherDepedencyToChangeRequest < ActiveRecord::Migration
  def change
    add_column :change_requests, :other_dependency, :text
  end
end
