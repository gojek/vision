# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :access_request_comment do
  	body Faker::Lorem.sentence(5)

    factory :ar_comment_with_mention do
      body "@" + Faker::Internet.user_name(Faker::Name.name, %w(. _ .)) + " @" + Faker::Internet.user_name(Faker::Name.name, %w(. _ .))
    end
  end
end
