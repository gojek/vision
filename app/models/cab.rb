class Cab < ActiveRecord::Base
	has_many :change_requests
end
