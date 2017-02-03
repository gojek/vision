require 'spec_helper'

describe Comment, type: :model do
  #shoulda matchers test
  it { should belong_to(:change_request)}
  it { should belong_to(:user)}
end
