class AccessRequestComment < ApplicationRecord
  belongs_to :access_request
  belongs_to :user
  validates :body, presence:true
end
