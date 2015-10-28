# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :cab do
    meet_date {Time.now + 3600}
    participant "adam.pahlevi@gmail.com,izumi.haneda@gmail.com"
    room "H280"
    
    factory :invalid_cab do
  		meet_date {Time.now - 3600}
  	end
  end
end
