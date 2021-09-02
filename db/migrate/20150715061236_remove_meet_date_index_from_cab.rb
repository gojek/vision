class RemoveMeetDateIndexFromCab < ActiveRecord::Migration[5.2]
  def down
  	remove_index(:cabs, :name => 'index_cabs_on_meet_date')
  end
end
