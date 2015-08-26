class AddClosedDateToChangeRequest < ActiveRecord::Migration
  def change
    add_column :change_requests, :closed_date, :datetime
  end
end
