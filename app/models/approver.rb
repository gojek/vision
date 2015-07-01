class Approver < ActiveRecord::Base
  belongs_to :change_request
end
