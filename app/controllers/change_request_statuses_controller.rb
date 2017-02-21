class ChangeRequestStatusesController < ApplicationController
	before_action :set_change_request, only:[:schedule, :deploy, :rollback, :cancel, :close, :final_reject, :submit]
	before_action :authorized_user_required, only:[:schedule, :deploy, :rollback, :cancel, :close, :final_reject, :submit]
  before_action :authenticate_user!

  private def alert_users(status:)
    if @change_request && @status
      begin
        UserMailer.notif_email(@change_request.user, @change_request, @status).deliver_now
        Notifier.cr_notify(current_user, @change_request, status)
      rescue => e
        Rails.logger.error e.message
        Rails.logger.error e.backtrace.join("\n")
      end
    else
      Rails.logger.error "Cannot notify users: change request and status object do not exist"
    end
  end

  def schedule
    if @change_request.may_schedule?
      @status = @change_request.change_request_statuses.new(change_request_status_params)
      @status.status = 'scheduled'
      if @status.save
        @change_request.schedule!
        alert_users status: 'cr_scheduled'
      end
    else
      flash[:danger] = 'Sorry, this CR didnt reach approval limit by Approver'
    end
    redirect_to @change_request
  end

  def deploy
    if @change_request.may_deploy?
    	@status = @change_request.change_request_statuses.new(change_request_status_params)
    	@status.status = 'deployed'
    	if @status.save
        @change_request.deploy!
        alert_users status: 'cr_deployed'
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
        alert_users status: 'cr_rollbacked'
      else
        flash[:danger] = 'Reason must be filled to Rollback CR'
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
        alert_users status: 'cr_cancelled'
      else
        flash[:danger] = 'Reason must be filled Cancel CR'
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
        alert_users status: 'cr_closed'
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
        alert_users status: 'cr_final_rejected'
      else
        flash[:danger] = 'Reason must be filled to Reject CR'
      end
    end
    redirect_to @change_request
  end

  def submit
    if @change_request.may_submit?
      @status = @change_request.change_request_statuses.new(change_request_status_params)
      @status.status = 'submitted'
      if @status.save
        @change_request.submit!
        UserMailer.notif_email(@change_request.user, @change_request, @status).deliver_now
        #no need to notify, because it same with new cr
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

  def authorized_user_required
    redirect_to @change_request unless
    current_user.role == 'release_manager' || current_user.is_admin || current_user.is_associated?(@change_request)
  end
end
