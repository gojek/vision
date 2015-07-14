class Cab < ActiveRecord::Base
	has_many :change_requests
	validates :meet_date, presence:true
end
