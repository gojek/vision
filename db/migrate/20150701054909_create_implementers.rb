class CreateImplementers < ActiveRecord::Migration
  def change
    create_table :implementers do |t|
      t.string :name
      t.string :position
      t.references :change_request, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
