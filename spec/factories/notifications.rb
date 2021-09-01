# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryBot.define do
  factory :notification do
    user nil
    change_request nil
    incident_report nil
    message "MyString"
  end
end
