class AddUserReftoTesters < ActiveRecord::Migration[5.2]
  def change
    add_reference :testers, :user, index: true, foreign_key: true
  end
end
