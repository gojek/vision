FactoryGirl.define do
  factory :comment do
    body Faker::Lorem.sentence(5)

    factory :comment_with_mention do
      body "@" + Faker::Internet.user_name(Faker::Name.name, %w(. _ .)) + " @" + Faker::Internet.user_name(Faker::Name.name, %w(. _ .))
    end
  end


end
