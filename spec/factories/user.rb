# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user do
    sequence(:email) { |n| "patrick#{n}@veritrans.co.id" }
    role 'requestor'
    provider 'google_oauth2'
    uid '123456'
    is_admin false
    name 'patrick star'
    locked_at nil
    token '123456'
    refresh_token '123456'
    expired_at Time.now+1.hour

    factory :admin do
        is_admin true
    end

    factory :release_manager do
        role 'release_manager'
    end

    factory :approval do
        role 'approver'
    end
  end
end
