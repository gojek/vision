FactoryGirl.define do
  factory :approval do
    notes "wah sangat bagus merupakan inovasi terbaik di jaman ini"
    before(:create) do |app|
      approver = FactoryGirl.create(:approver)
      app.user = approver
    end
  end
end
