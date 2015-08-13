class AddParticipantsToCab < ActiveRecord::Migration
  def change
    add_column :cabs, :participant, :string
  end
end
