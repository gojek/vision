FactoryGirl.define do
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
    testing_notes "Notes"
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

    trait :invalid_change_request do
        scope "Scope"
    end

    before(:create) do |cr|
      collaborator = FactoryGirl.create(:user)
      cr.collaborators << collaborator

      implementer = FactoryGirl.create(:user)
      cr.implementers << implementer

      tester = FactoryGirl.create(:user)
      cr.testers << tester

      approval = FactoryGirl.create(:approval)
      cr.approvals << approval

      associated_user_ids = [collaborator.id, implementer.id, tester.id, approval.user.id]
      cr.associated_user_ids = associated_user_ids.uniq
    end

    after(:build) do |cr|
      approval = FactoryGirl.create(:approval)
      cr.approvals << approval
    end
  end
end
