# app/jobs/change_request_job.rb

class ChangeRequestJob 
  include SuckerPunch::Job 
  require 'sucker_punch/async_syntax'


  def perform(cr_ids, email)
    ApplicationRecord.connection_pool.with_connection do
      csv_string = CSV.generate do |csv|
        csv << ChangeRequest.attribute_names
        ChangeRequest.where(id: cr_ids).where.not(aasm_state: 'draft').order("created_at DESC").each do |cr|
          csv << cr.attributes.values
        end
      end
      ChangeRequestMailer.send_csv(csv_string, email).deliver_later
    end
  end
end