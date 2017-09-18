class ChangeRequestStatusesController < ApplicationController
	before_action :set_change_request, only:[:deploy, :rollback, :cancel, :close, :fail, :submit]
	before_action :authorized_user_required, only:[:deploy, :rollback, :cancel, :close, :fail, :submit]
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

  def deploy
    if @change_request.may_deploy? && @change_request.deployable?
    	@status = @change_request.change_request_statuses.new(change_request_status_params)
    	@status.status = 'deployed'
    	if @status.save
        @change_request.deploy!
        alert_users status: 'cr_deployed'
      else
        flash[:alert] = 'Reason must be filled to Deploy delayed CR'
      end
    else
      flash[:alert] = 'Sorry, this CR should be approved by all Approver first'
    end
    redirect_to @change_request
  end

  def fail
    if @change_request.may_fail?
      @status = @change_request.change_request_statuses.new(change_request_status_params)
      @status.status = 'failed'
      if @status.save
        @change_request.fail!
        alert_users status: 'cr_failed'
      else
        flash[:alert] = 'Reason must be filled to Fail CR'
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
        flash[:alert] = 'Reason must be filled to Rollback CR'
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
        flash[:alert] = 'Reason must be filled to Cancel CR'
      end
    end
    redirect_to @change_request
  end

  def close
    if @change_request.may_close?
      @status = @change_request.change_request_statuses.new(change_request_status_params)
      @status.status = 'succeeded'
      if @status.save
        @change_request.close!
        alert_users status: 'cr_closed'
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
  	params.require(:change_request_status).permit(:reason, :deploy_delayed)
  end

  def authorized_user_required
    redirect_to @change_request unless
    current_user.role == 'release_manager' || current_user.is_admin || current_user.is_associated?(@change_request)
  end
end
