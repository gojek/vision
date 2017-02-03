require 'spec_helper'

describe ChangeRequestStatus, type: :model do

  #shoulda matchers test
  it { should belong_to(:change_request)}

  it "need reason if CR status either rollbacked, cancelled or rejected" do
  	change_request_status = ChangeRequestStatus.create(
  		status: 'rollbacked')
    change_request_status.valid?
    expect(change_request_status.errors[:reason].size).to eq(1)
  	other_change_request_status = ChangeRequestStatus.create(
  		status: 'cancelled')
    other_change_request_status.valid?
    expect(other_change_request_status.errors[:reason].size).to eq(1)
  	another_change_request_status = ChangeRequestStatus.create(
  		status: 'rejected')
    another_change_request_status.valid?
    expect(another_change_request_status.errors[:reason].size).to eq(1)
  end
end
