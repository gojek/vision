class AddClosedDateToChangeRequest < ActiveRecord::Migration[5.2]
  def change
    add_column :change_requests, :closed_date, :datetime
  end
end
