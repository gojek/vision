class FixColumnTypeNameChangeRequest < ActiveRecord::Migration[5.2]
  def self.up
    rename_column :change_requests, :type, :cr_type
  end

  def self.down
    # rename back if you need or do something else or do nothing
  end
end
