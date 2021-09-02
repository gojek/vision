class CreateChangeRequests < ActiveRecord::Migration[5.2]
  def change
    create_table :change_requests do |t|
      t.string :requestor_desc
      t.string :priority
      t.string :category
      t.string :type
      t.text :change_requirement
      t.text :business_justification
      t.string :requestor_position
      t.text :note
      t.text :analysis
      t.text :solution
      t.text :impact
      t.string :scope
      t.text :design
      t.text :backup
      t.text :restore
      t.boolean :testing_environment_available
      t.text :testing_procedure
      t.text :testing_notes
      t.datetime :schedule_change_date
      t.datetime :planned_completion
      t.datetime :grace_period_starts
      t.datetime :grace_period_end
      t.text :implementation_notes
      t.text :grace_period_notes
      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
