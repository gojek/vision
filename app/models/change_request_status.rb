class ChangeRequestStatus < ActiveRecord::Base
  belongs_to :change_request
  validates :reason, presence: true, if: :reason_needed?

  private
  def reason_needed?
    (['cancelled', 'failed', 'rollbacked'].include? self.status) || self.deploy_delayed
  end

end
