# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "patrick#{n}@gmail.com" }
    role 'requestor'
    provider 'google_oauth2'
    sequence(:uid) { |n| "#{n}"}
    is_admin false
    name 'patrick star'
    locked_at nil
    token '123456'
    refresh_token '123456'
    position 'Software Engineer 1'
    expired_at Time.now + 7.days
    is_approved 3

    factory :admin do
        is_admin true
        is_approved 3
    end

    factory :release_manager do
        role 'release_manager'
        is_approved 3
    end

    factory :approver do
        role 'approver'
        is_approved 3
    end

    factory :master_approver do
      role 'approver_all'
      is_approved 3
      email 'approver@gmail.com'
    end
    
    factory :approver_ar do
        role 'approver_ar'
        is_approved 3
    end

    factory :waiting_user do
        is_approved 2
    end

    factory :pending_user do
        is_approved 1
    end

    factory :rejected_user do
        is_approved 0
        sequence(:email) { |n| "patrick#{n}@gmail.com" }
    end

    factory :old_email do
        email 'dummy@engineering.com'
    end
  end
end
