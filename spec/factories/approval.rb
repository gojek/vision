FactoryBot.define do
  factory :approval do
    approve nil
    notes "wah sangat bagus merupakan inovasi terbaik di jaman ini"
    before(:create) do |app|
      approver = FactoryBot.create(:approver)
      app.user = approver
    end
  end
end
