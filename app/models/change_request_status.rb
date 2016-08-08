class ChangeRequestStatus < ActiveRecord::Base
  belongs_to :change_request
  validates :reason, presence: true, if: :reason_needed?

    private

  def reason_needed?
    self.status=='rollbacked' || self.status=='cancelled' || self.status=='rejected'
  end

end
