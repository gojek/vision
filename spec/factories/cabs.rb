# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :cab do
    meet_date {Time.now}
  end
end
