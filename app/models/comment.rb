class Comment < ActiveRecord::Base
  belongs_to :change_request
  belongs_to :user
  validates :body, presence:true
end
