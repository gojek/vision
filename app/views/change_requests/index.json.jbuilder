json.array!(@change_requests) do |change_request|
  json.extract! change_request, :id, :change_summary, :priority, :category, :type, :change_requirement, :business_justification, :requestor_position, :note, :analysis, :solution, :impact, :scope, :design, :backup, :testing_environment_available, :testing_procedure, :testing_notes, :schedule_change_date, :planned_completion, :grace_period_starts, :grace_period_end, :implementation_notes, :grace_period_notes, :user_id
  json.url change_request_url(change_request, format: :json)
end
