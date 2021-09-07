class UpdatePriority < ActiveRecord::Migration[5.2]
  def change
  	ChangeRequest.where(priority: ['Critical', 'Urgent']).update_all(priority: 'High')
  	ChangeRequest.where(priority: 'Normal').update_all(priority: 'Medium')
  end
end
