require 'rails_helper'

RSpec.describe AccessRequestComment, type: :model do
  
  it { should belong_to(:access_request)}
  it { should belong_to(:user)}
end
