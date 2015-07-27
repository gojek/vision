FactoryGirl.define do
  factory :change_request do
    change_summary "Change Summary"
    priority "Low"
    category "Other"
    cr_type "Other"
    change_requirement "Change Requirement"
    business_justification "Business Justification"
    requestor_name "Patrick"
    requestor_position "Software Engineer"
    note "Note"
    net "Net"
    db "Db"
    os "Os"
    analysis "Analysis"
    solution "Solution"
    impact "Impact"
    scope "Minor"
    design "Design"
    backup "Backup"
    testing_environment_available true
    testing_procedure "Procedure"
    testing_notes "Notes"
    schedule_change_date {Time.now}
    planned_completion {Time.now}
    grace_period_starts {Time.now}
    grace_period_end {Time.now}
    implementation_notes "Implementation Notes"
    grace_period_notes "Grace Period Notes"

    factory :submitted_change_request do
      aasm_state 'submitted'
    end

    factory :scheduled_change_request do
        aasm_state 'scheduled'
    end

    factory :rejected_change_request do
        aasm_state 'rejected'
    end

    factory :deployed_change_request do
        aasm_state 'deployed'
    end

    factory :rollbacked_change_request do
        aasm_state 'rollbacked'
    end

    factory :cancelled_change_request do
        aasm_state 'cancelled'
    end

    factory :closed_change_request do
        aasm_state 'closed'
    end

    factory :invalid_change_request do
        scope "Scope"
    end
  end
end