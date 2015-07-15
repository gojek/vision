class Cab < ActiveRecord::Base
	has_many :change_requests, dependent: :nullify
	validates :meet_date, presence:true, uniqueness:true
	validate :validate_meet_date

	def validate_meet_date
		errors.add("Meet date", "is invalid.") unless meet_date > Time.now
	end
end
