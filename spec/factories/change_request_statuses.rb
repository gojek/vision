# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryBot.define do
  factory :change_request_status do
    status "Scheduled"
    reason "reason"
  end
end
