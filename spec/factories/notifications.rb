# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :notification do
    user nil
    change_request nil
    incident_report nil
    read false
    message "MyString"
  end
end
