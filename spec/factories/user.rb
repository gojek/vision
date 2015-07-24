# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user do
    email 'patrick@veritrans.co.id'
    role 'requestor'
    provider 'google_oauth2'
    uid '123456'
    is_admin false
    name 'patrick star'
    locked_at nil
  end
end
