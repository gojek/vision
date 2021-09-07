class AddParticipantsToCab < ActiveRecord::Migration[5.2]
  def change
    add_column :cabs, :participant, :string
  end
end
