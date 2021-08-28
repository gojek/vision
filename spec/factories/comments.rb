FactoryGirl.define do
  factory :comment do
    body Faker::Lorem.sentence(word_count: 5)

    factory :comment_with_mention do
      body "@" + Faker::Internet.user_name(specifier: Faker::Name.name, separators: %w(. _ .)) + " @" + Faker::Internet.user_name(specifier: Faker::Name.name, separators: %w(. _ .))
    end
  end


end
