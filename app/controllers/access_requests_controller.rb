class AccessRequestsController < ApplicationController
  before_action :authenticate_user!

  def index
    @q = AccessRequest.ransack(params[:q])
    @access_requests = @q.result(distinct: true).order(id: :desc)

    respond_to do |format|
      format.html do
        @access_requests = @access_requests.page(params[:page]).per(params[:per_page])
      end
    end
  end

  def new
    @access_request = AccessRequest.new
    @access_request.approvals
    @access_request.collaborators
    @users = User.all.collect{|u| [u.name, u.id]}
    @approvers = User.approvers.collect{|u| [u.name, u.id] if u.id != current_user.id }
  end

  private

    def access_request_params
      params.require(:access_requests)
    end
end
