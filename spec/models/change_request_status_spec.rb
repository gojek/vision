require 'spec_helper'

describe ChangeRequestStatus do

  #shoulda matchers test
  it { should belong_to(:change_request)}

  it "need reason if CR status either rollbacked, cancelled or rejected" do
  	change_request_status = ChangeRequestStatus.create(
  		status: 'rollbacked')
  	expect(change_request_status).to have(1).errors_on(:reason)
  	other_change_request_status = ChangeRequestStatus.create(
  		status: 'cancelled')
  	expect(other_change_request_status).to have(1).errors_on(:reason)
  	another_change_request_status = ChangeRequestStatus.create(
  		status: 'rejected')
  	expect(another_change_request_status).to have(1).errors_on(:reason)
  end
end
