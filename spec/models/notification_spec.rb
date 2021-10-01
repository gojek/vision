require 'rails_helper'

describe Notification, type: :model do
  it { should belong_to(:change_request).optional }
  it { should belong_to(:incident_report).optional }
  it { should belong_to(:user).optional }
end
