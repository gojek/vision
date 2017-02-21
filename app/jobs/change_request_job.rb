# app/jobs/change_request_job.rb

class ChangeRequestJob 
  include SuckerPunch::Job 

  def perform(cr_ids, email)
    csv_string = CSV.generate do |csv|
      csv << ChangeRequest.attribute_names
      ChangeRequest.where(id: cr_ids).where.not(aasm_state: 'draft').order("created_at DESC").each do |cr|
        csv << cr.attributes.values
  	  end
	  end
    ActiveRecord::Base.connection_pool.with_connection do
		  ChangeRequestMailer.send_csv(csv_string, email).deliver_now
    end
  end
end
