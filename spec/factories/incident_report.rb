FactoryGirl.define do
  factory :incident_report do
    service_impact "Service impact"
    problem_details "Problem details"
    how_detected "How detected"
    occurrence_time {3.days.ago}
    detection_time {2.days.ago}
    acknowledge_time  {1.day.ago}
    resolved_time {Time.now}
    source "Internal"
    rank 1
    loss_related  "lost"
    occurred_reason "reason"
    overlooked_reason "overlooked_reason"
    recovery_action "recovery_action"
    prevent_action "prevent_action"
    recurrence_concern "Low"
    current_status "Acknowledged"
    measurer_status "Implemented"
    user {FactoryGirl.create(:user)}
    entity_source "Midtrans"

    factory :invalid_incident_report do 
      service_impact "Service impact"
      problem_details "Problem details"
      how_detected "How detected"
      occurrence_time {2.days.ago}
      detection_time {1.days.ago}
      acknowlegde_time  {Time.now}
      resolved_time {Time.now}
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
      user {FactoryGirl.create(:user)}
    end

    factory :incident_report_with_reason_update do 
      service_impact "Service impact"
      problem_details "Problem details"
      how_detected "How detected"
      occurrence_time {2.days.ago}
      detection_time {1.days.ago}
      acknowlegde_time  {Time.now}
      resolved_time {Time.now}
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
      user {FactoryGirl.create(:user)}
      reason "reason"
    end

    factory :jira_incident_report do
      has_further_action true
      action_item "TEST-123"
      action_item_status "In Progress"
    end
    
  end  

end
