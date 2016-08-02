require 'spec_helper'

describe Notification, type: :model do
  it { should belong_to(:change_request)}
  it { should belong_to(:incident_report)}
  it { should belong_to(:user)}
end
