class Cab < ActiveRecord::Base
	has_many :change_requests, dependent: :nullify
	validates :meet_date, presence:true
end
