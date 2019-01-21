# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :transfer_email do
    old_email "MyString"
    new_email "MyString"
    is_changed false
  end
end
