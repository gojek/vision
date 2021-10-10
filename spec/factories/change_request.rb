FactoryBot.define do
  factory :change_request do
    # change_summary "Change Summary"
    sequence(:change_summary) { |n| "Change Summary #{n}" }
    priority "Low"
    type_install_uninstall true
    category_server true
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
    schedule_change_date {Time.now}
    planned_completion {3.days.from_now}
    grace_period_starts {Time.now}
    grace_period_end {3.days.from_now}
    implementation_notes "Implementation Notes"
    grace_period_notes "Grace Period Notes"
    definition_of_success "Success"
    definition_of_failed " Failed"
    category_application true
    type_other "other type"
    entity_source "engineering"

    factory :submitted_change_request do
      aasm_state 'submitted'
    end

    factory :scheduled_change_request do
      aasm_state 'succeeded'
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

    factory :draft_change_request do
      aasm_state 'draft'
    end

    factory :jira_change_request do
      net "TEST-123"
      db "TEST-123"
      os "TEST-123"
      analysis "TEST-123"
      solution "TEST-123"
      impact "TEST-999"
    end

    trait :invalid_change_request do
      scope "Scope"
    end

    before(:create) do |cr|
      collaborator = FactoryBot.create(:user)
      cr.collaborators << collaborator

      implementer = FactoryBot.create(:user)
      cr.implementers << implementer

      tester = FactoryBot.create(:user)
      cr.testers << tester

      approval = FactoryBot.create(:approval)
      cr.approvals << approval

    end

    after(:create) do |cr|
      status = FactoryBot.create(:change_request_status, status: 'submitted')
      cr.update(change_request_statuses: cr.change_request_statuses << status)
    end

    after(:build) do |cr|
      approval = FactoryBot.create(:approval)
      cr.approvals << approval
    end
  end
end
