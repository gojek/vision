class Cab < ActiveRecord::Base
  extend SimpleCalendar
  has_many :change_requests, dependent: :nullify
  validates :meet_date, presence:true, uniqueness:true
  validate :validate_meet_date
  PARTICIPANTS = %w(cr@veritrans.co.id it_operation@veritrans.co.id stig@veritrans.co.id)
  def validate_meet_date
    errors.add("Meet date", "is invalid.") unless meet_date!=nil && meet_date > Time.now
  end
end
