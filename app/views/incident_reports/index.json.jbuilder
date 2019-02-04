json.array!(@incident_reports) do |incident_report|
  json.extract! incident_report, :id, :service_impact, :problem_details, :how_detected, :occurrence_time, :detection_time, :acknowledge_time, :source, :rank, :loss_related, :occurred_reason, :overlooked_reason, :recovery_action, :prevent_action, :recurrence_concern, :current_status, :measurer_status, :user_id, :time_to_acknowledge
  json.url incident_report_url(incident_report, format: :json)
end
