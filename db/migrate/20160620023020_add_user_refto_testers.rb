class AddUserReftoTesters < ActiveRecord::Migration
  def change
    add_reference :testers, :user, index: true, foreign_key: true
  end
end
