class RemoveMeetDateIndexFromCab < ActiveRecord::Migration
  def down
  	remove_index(:cabs, :name => 'index_cabs_on_meet_date')
  end
end
