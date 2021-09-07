class UpdateChangeRequestStatus < ActiveRecord::Migration[5.2]
  def change
  	ChangeRequest.where(status: 'failed').update_all(aasm_state: 'failed')
  	ChangeRequest.where(status: 'success').update_all(aasm_state: 'succeeded')
  	ChangeRequest.where(aasm_state: 'scheduled').update_all(aasm_state: 'submitted')
  end
end
