require 'spec_helper'

describe Cab do
  it "is invalid if assigned with past meet date" do
  	cab = FactoryGirl.build(:cab, meet_date: Time.now-3600)
  	expect(cab).to be_invalid
  end

  it "is valid if assigned with future meet date" do
  	cab = FactoryGirl.build(:cab, meet_date: Time.now+3600)
  	expect(cab).to be_valid
  end
end
