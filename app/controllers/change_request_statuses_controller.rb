class ChangeRequestStatusesController < ApplicationController
	before_action :set_change_request, only:[:schedule, :deploy, :rollback, :cancel, :close, :final_reject, :submit]
	def schedule
    @status = @change_request.change_request_statuses.new
    @status.status = 'scheduled'
    if @status.save
      @change_request.schedule!
    end
    redirect_to @change_request
  end
  def deploy
  	@status = @change_request.change_request_statuses.new
  	@status.status = 'deployed'
  	if @status.save
      @change_request.deploy!
    end
    redirect_to @change_request
  end

  def rollback
    @status = @change_request.change_request_statuses.new(change_request_status_params)
    @status.status = 'rollbacked'
    if @status.save
      @change_request.rollback!
    end
    redirect_to @change_request
  end
  
  def cancel
    @status = @change_request.change_request_statuses.new(change_request_status_params)
    @status.status = 'cancelled'
    if @status.save
      @change_request.cancel!
    end
    redirect_to @change_request
  end
  
  def close
    @status = @change_request.change_request_statuses.new(change_request_status_params)
    @status.status = 'closed'
    if @status.save
      @change_request.close!
    end
    redirect_to @change_request
  end

  def final_reject
    @status = @change_request.change_request_statuses.new(change_request_status_params)
    @status.status = 'rejected'
    if @status.save
      @change_request.reject!
    end
    redirect_to @change_request
  end

  def submit
    @status = @change_request.change_request_statuses.new
    @status.status = 'submitted'
    if @status.save
      @change_request.submit!
    end
    redirect_to @change_request
  end

  private
  
  def set_change_request
  	@change_request = ChangeRequest.find(params[:id])
  end
  
  def change_request_status_params
  	params.require(:change_request_status).permit(:reason)
  end

end
