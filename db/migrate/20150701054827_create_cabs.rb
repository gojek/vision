class CreateCabs < ActiveRecord::Migration
  def change
    create_table :cabs do |t|
      t.string :name
      t.string :position
      t.boolean :approve
      t.text :reason
      t.references :change_request, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
