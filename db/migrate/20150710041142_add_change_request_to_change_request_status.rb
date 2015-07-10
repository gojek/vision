class AddChangeRequestToChangeRequestStatus < ActiveRecord::Migration
  def change
    add_reference :change_request_statuses, :change_request, index: true, foreign_key: true
  end
end
