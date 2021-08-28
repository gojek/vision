# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :access_request_comment do
    body Faker::Lorem.sentence(word_count: 5)
  end
end
