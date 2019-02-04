class ChangeIsApproveValueOfExistingUserToApproved < ActiveRecord::Migration
  def up
    execute <<-SQL
      UPDATE users SET is_approved = 3;
    SQL
  end

  def down
    execute <<-SQL
      UPDATE users SET is_approved = 1;
    SQL
  end
end
