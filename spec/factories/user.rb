# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user do
    sequence(:email) { |n| "patrick#{n}@veritrans.co.id" }
    role 'requestor'
    provider 'google_oauth2'
    sequence(:uid) { |n| "#{n}"}
    is_admin false
    name 'patrick star'
    locked_at nil
    token '123456'
    refresh_token '123456'
    position 'Software Engineer 1'
    expired_at Time.now + 14.days

    factory :admin do
        is_admin true
    end

    factory :release_manager do
        role 'release_manager'
    end

    factory :approver do
        role 'approver'
    end
    
    factory :approver_ar do
        role 'approver_ar'
    end
  end
end
