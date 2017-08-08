class UpdatePriority < ActiveRecord::Migration
  def change
  	ChangeRequest.where(priority: ['Critical', 'Urgent']).update_all(priority: 'High')
  	ChangeRequest.where(priority: 'Normal').update_all(priority: 'Medium')
  end
end
