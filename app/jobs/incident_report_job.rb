# app/jobs/incident_report_job.rb

class IncidentReportJob
  include SuckerPunch::Job
  require 'sucker_punch/async_syntax'


  CSV_COLUMNS = [
    'id',
    'service impact', 
    'problem details', 
    'current status', 
    'rank', 
    'measurer status', 
    'recurrence concern', 
    'occurrence time', 
    'detection time', 'recovery time', 
    'recovery duration', 
    'resolved time', 
    'how was problem detected', 
    'loss related issue'
  ]

  def perform(ir_ids, email)
    ApplicationRecord.connection_pool.with_connection do
      csv_string = CSV.generate do |csv|
        csv << CSV_COLUMNS
        IncidentReport.where(id: ir_ids).order('created_at DESC').find_in_batches do |group|
          group.each do |ir|
            csv << get_data(ir)
          end
        end
      end
      IncidentReportMailer.send_csv(csv_string, email).deliver_later
    end  
  end

  def get_data(ir)
    [
      ir.id, ir.service_impact, ir.problem_details,     
      ir.current_status, ir.rank, ir.measurer_status, ir.recurrence_concern,    
      ir.occurrence_time, ir.detection_time,
      ir.recovery_duration, ir.resolved_time, ir.how_detected, ir.loss_related
    ]
  end
end
