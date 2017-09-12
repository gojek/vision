FactoryGirl.define do
  factory :access_request_approval do
    approved nil
    notes "wah sangat bagus merupakan inovasi terbaik di jaman ini"
    before(:create) do |app|
      approver = FactoryGirl.create(:approver_ar)
      app.user = approver
    end
  end
end
