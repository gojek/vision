class AccessRequestComment < ActiveRecord::Base
  belongs_to :access_request
  belongs_to :user
  validates :body, presence:true
end
