class CreateCabs < ActiveRecord::Migration
  def change
    create_table :cabs do |t|
      t.datetime :meet_date

      t.timestamps null: false
    end
    add_index :cabs, :meet_date, unique: true
  end
end
