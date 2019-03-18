FactoryGirl.define do
  factory :access_request do
    ignore do
      temporary false
      collaborators_num 5
      approvals_alpha 5
      approvals_accept 0
      approvals_reject 0
    end

    request_type 'Create'
    access_type 'Permanent'
    start_date nil
    end_date nil

    employee_name 'Employee Name'
    business_justification 'Business Justification'
    employee_position 'Employee Position'
    employee_email_address 'employee@email.address'
    employee_department 'Employee Department'
    employee_phone '+62000000000'

    employee_access true
    fingerprint_business_area false
    fingerprint_business_operations true
    fingerprint_it_operations true
    fingerprint_server_room false
    fingerprint_archive_room false
    fingerprint_engineering_area true

    corporate_email 'employee@corporate.email'

    internet_access true
    slack_access true
    admin_tools false
    vpn_access true
    github_gitlab true
    exit_interview false
    access_card true
    parking_cards false
    id_card false
    name_card false
    insurance_card false
    cash_advance true
    metabase true
    solutions_dashboard true

    password_reset true
    user_identification 'user_identification'
    asset_name 'Asset Name'

    factory :draft_access_request do
      aasm_state 'draft'
    end

    factory :submitted_access_request do
      aasm_state 'submitted'
      request_date Time.current
    end

    factory :closed_access_request do
      aasm_state 'succeeded'
    end

    factory :cancelled_access_request do
      aasm_state 'cancelled'
    end

    before(:create) do |ar, evaluator|
      if evaluator.temporary
        ar.access_type = 'Temporary'
        ar.start_date = 3.days.from_now
        ar.end_date = 4.days.from_now
      end

      ar.user = FactoryGirl.create(:user)

      evaluator.collaborators_num.times do |i|
        ar.collaborators << FactoryGirl.create(:user)
      end
      
      evaluator.approvals_accept.times do |i|
        ar.approvals << FactoryGirl.create(:access_request_approval, approved: true)
      end
      evaluator.approvals_reject.times do |i|
        ar.approvals << FactoryGirl.create(:access_request_approval, approved: false)
      end
      evaluator.approvals_alpha.times do |i|
        ar.approvals << FactoryGirl.create(:access_request_approval, approved: nil)
      end
    end
  end
end
