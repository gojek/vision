# app/jobs/incident_report_job.rb

class IncidentReportJob
  include SuckerPunch::Job

  def perform(ir_ids, email)
    csv_string = CSV.generate do |csv|
      csv << IncidentReport.attribute_names
      IncidentReport.where(id: ir_ids).order('created_at DESC').each do |ir|
        csv << ir.attributes.values
      end
    end
    ActiveRecord::Base.connection_pool.with_connection do
	  IncidentReportMailer.send_csv(csv_string, email).deliver_now
    end
  end
end