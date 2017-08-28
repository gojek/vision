class AccessRequestStatus < ActiveRecord::Base
  belongs_to :access_request
  validates :reason, presence: true, if: :reason_needed?

  private

    def reason_needed?
      ['cancelled'].include? self.status
    end

end
