# app/jobs/incident_report_job.rb

class IncidentReportJob
  include SuckerPunch::Job

  def perform(ir_ids, email)
    csv_string = CSV.generate do |csv|
      csv << IncidentReport.attribute_names
      IncidentReport.where(id: ir_ids).order('created_at DESC').each do |ir|
        csv << ir.attribute.values
      end
    end
  end
end