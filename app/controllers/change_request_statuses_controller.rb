class ChangeRequestStatusesController < ApplicationController
	before_action :set_change_request, only:[:schedule, :deploy, :rollback, :cancel, :close, :final_reject, :submit]
	before_action :release_manager?, only:[:schedule, :deploy, :rollback, :cancel, :close, :final_reject, :submit]
  def schedule
    if @change_request.may_schedule?
      @status = @change_request.change_request_statuses.new
      @status.status = 'scheduled'
      if @status.save
        @change_request.schedule!
      end
    end
    redirect_to @change_request
  end

  def deploy
    if @change_request.may_deploy?
    	@status = @change_request.change_request_statuses.new
    	@status.status = 'deployed'
    	if @status.save
        @change_request.deploy!
      end
    end
    redirect_to @change_request
  end

  def rollback
    if @change_request.may_rollback?
      @status = @change_request.change_request_statuses.new(change_request_status_params)
      @status.status = 'rollbacked'
      if @status.save
        @change_request.rollback!
      end
    end
    redirect_to @change_request
  end
  
  def cancel
    if @change_request.may_cancel?
      @status = @change_request.change_request_statuses.new(change_request_status_params)
      @status.status = 'cancelled'
      if @status.save
        @change_request.cancel!
      end
    end
    redirect_to @change_request
  end
  
  def close
    if @change_request.may_close?
      @status = @change_request.change_request_statuses.new(change_request_status_params)
      @status.status = 'closed'
      if @status.save
        @change_request.close!
      end
    end
    redirect_to @change_request
  end

  def final_reject
    if @change_request.may_reject?
      @status = @change_request.change_request_statuses.new(change_request_status_params)
      @status.status = 'rejected'
      if @status.save
        @change_request.reject!
      end
    end
    redirect_to @change_request
  end

  def submit
    if @change_request.may_submit?
      @status = @change_request.change_request_statuses.new
      @status.status = 'submitted'
      if @status.save
        @change_request.submit!
      end
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
  
  def release_manager?
    redirect_to @change_request if current_user.role != 'release_manager'
  end
end
