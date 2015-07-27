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

    factory :admin do
        is_admin true
    end

    factory :release_manager do
        role 'release_manager'
    end

    factory :approver do
        role 'approver'
    end
  end
end
