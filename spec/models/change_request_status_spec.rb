require 'rails_helper'

describe ChangeRequestStatus, type: :model do

  #shoulda matchers test
  it { should belong_to(:change_request)}

  it "need reason if CR status either cancelled, failed, rollbacked" do
    ['cancelled', 'failed', 'rollbacked'].each do |status|
      change_request_status = ChangeRequestStatus.create(status: status)
      expect(change_request_status).to validate_presence_of(:reason)
    end
  end
end
