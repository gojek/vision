FactoryGirl.define do
  factory :incident_report do
    service_impact "Service impact"
    problem_details "Problem details"
    how_detected "How detected"
    occurrence_time {Time.now}
    detection_time {Time.now}
    recovery_time  {Time.now}
    source "Internal"
    rank 1
    loss_related  "lost"
    occurred_reason "reason"
    overlooked_reason "overlooked_reason"
    recovery_action "recovery_action"
    prevent_action "prevent_action"
    recurrence_concern "Low"
    current_status "Recovered"
    measurer_status "Implemented"

    factory :invalid_incident_report do 
        service_impact "Service impact"
        problem_details "Problem details"
        how_detected "How detected"
        occurrence_time {Time.now}
        detection_time {Time.now}
        recovery_time  {Time.now}
        source "Internal"
        rank 1
        loss_related  "lost"
        occurred_reason "reason"
        overlooked_reason "overlooked_reason"
        recovery_action "recovery_action"
        prevent_action "prevent_action"
        recurrence_concern "Low"
        current_status "curent"
        measurer_status "Implemented"
      end
    end  
end