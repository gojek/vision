
class AccessRequestsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_access_request, except: [:index, :new, :create, :search, :import_from_csv]
  before_action :authorized_to_change_status, only: [:cancel, :close]
  before_action :set_access_request_reason, only: [:cancel, :close]
  before_action :set_access_request_approval, only: [:approve, :reject]
  before_action :set_users_and_approvers, only: [:new, :edit]
  before_action :set_paper_trail_whodunnit
  require 'notifier.rb'
  require 'slack_notif.rb'
  require 'csv_exporter.rb'

  def index
    if params[:type]
      @q = AccessRequest.ransack(params[:q])
      case params[:type]
      when 'relevant'
        @access_requests = AccessRequest.relevant_access_requests(current_user)
      when 'approval'
        @access_requests = AccessRequest.where(id: AccessRequestApproval.where(user_id: current_user.id, approved: nil).collect(&:access_request_id))
      end
      @access_requests = @access_requests.where.not(aasm_state: 'draft').order(id: :desc)
    else
      @q = AccessRequest.ransack(params[:q])
      @access_requests = @q.result(distinct: true).order(id: :desc)
    end
    @tags = ActsAsTaggableOn::Tag.all.collect(&:name)
    @access_requests = @access_requests.page(params[:page]).per(params[:per_page])
    respond_to do |format|
      format.html
      format.csv do
        self.stream("Access Requests.csv", 'text/csv', CSVExporter.export_from_active_records(@access_requests))
      end
    end
  end

  def new
    @access_request = AccessRequest.new
  end

  def create
    AccessRequest.transaction do
      @access_request = current_user.AccessRequests.build(access_request_params)
      if @access_request.save
        if @access_request.draft?
          @access_request.submit!
        end
        NewAccessRequestSlackNotificationJob.perform_async(@access_request)
        flash[:success] = 'Access request was successfully created.'
      else
        @access_request.save(validate: false)
        flash[:notice] = 'Access request was created as a draft.'
        flash[:invalid] = @access_request.errors.full_messages
      end
    end

    redirect_to @access_request
  end

  def show
    @access_request_status = AccessRequestStatus.new
    @usernames = []
    User.active.each do |user|
      @usernames <<  user.email.split("@").first
    end
  end

  def edit
  end

  def search
    if params[:search].blank?
      redirect_to access_requests_path
    end
    @search = AccessRequest.solr_search do
      fulltext params[:search], highlight: true
      order_by(:created_at, :desc)
      paginate page: params[:page] || 1, per_page: 20
    end
  end

  def update
    @current_approvers = Array.wrap(access_request_params[:approvers_ids])
    @current_collaborators = Array.wrap(access_request_params[:collaborators_ids])
    if @access_request.update(access_request_params)
      if @access_request.draft?
        @access_request.submit!
        NewAccessRequestSlackNotificationJob.perform_async(@access_request)
      end
      flash[:success] = 'Access request was successfully edited.'
    else
      @access_request.save(:validate=> false)
      flash[:notice] = 'Access request was edited as a draft.'
      flash[:invalid] = @access_request.errors.full_messages
    end

    redirect_to @access_request
  end

  def destroy
    @access_request.destroy
    respond_to do |format|
      flash[:success] = 'Access request was successfully destroyed.'
      format.html { redirect_to access_requests_url }
      format.json { head :no_content }
    end
  end

  def import_from_csv
    fileExtension = File.extname(params[:csv].original_filename)
    if fileExtension != ".csv"
      flash[:alert] = 'Uploaded file is not a csv file. Please upload a csv file.'
      redirect_to access_requests_path
    end

    @valid, @invalid = AccessRequestsCsvParser.process_csv(params[:csv], current_user)

    AccessRequest.transaction do
      @valid.each do |access_request|
        access_request.save
        if access_request.draft?
          access_request.submit!
        end
        NewAccessRequestSlackNotificationJob.perform_async(access_request)
      end

      @invalid.each do |access_request|
        access_request.save(validate: false)
      end
    end

    if @valid.length > 0
      flash[:notice] = @valid.length.to_s + ' Access request(s) was successfully created.'
    end
    
    if @invalid.length > 0
      flash[:invalid] = @invalid.length.to_s + " data(s) is not filled correctly, the data was saved as a draft"
    end
    redirect_to access_requests_path
  end

  def cancel
    if @access_request.may_cancel?
      unless @access_request.cancel!
        flash[:alert] = @access_request.errors.full_messages.to_sentence
      end
    else
      flash[:alert] = 'AR can\'t be cancelled'
    end
    redirect_to @access_request
  end

  def close
    if @access_request.may_close? && @access_request.closeable?
      unless @access_request.close!
        flash[:alert] = @access_request.errors.full_messages.to_sentence
      end
    else
      flash[:alert] = 'AR can\'t be closed'
    end
    redirect_to @access_request
  end

  def approve
    AccessRequest.transaction do
      if @approval.update(approved: true, notes: params["notes"])
        flash[:success] = 'Access Request approved'
        if @access_request.vision_access
          user = User.action_from_access_request(@access_request, 'approve') 
          UserRequestMailer.approve_email(user).deliver_later
        end
      else
        flash[:notice] = @approval.errors.full_messages.to_sentence
      end
      redirect_to @access_request
    end
  end

  def reject
    AccessRequest.transaction do
      if @approval.update(approved: false, notes: params["notes"])
        flash[:success] = 'Access Request rejected'
        if @access_request.vision_access
          user = User.action_from_access_request(@access_request, 'reject') 
          UserRequestMailer.reject_email(user).deliver_later
        end
      else
        flash[:notice] = @approval.errors.full_messages.to_sentence
      end
      redirect_to @access_request
    end   
  end

  private

  def set_access_request
    if params[:access_request_id]
      @access_request = AccessRequest.find(params[:access_request_id])
    else
      @access_request = AccessRequest.find(params[:id])
    end
  end

  def access_request_params
    params
      .require(:access_request)
      .permit(
        :request_type,
        :access_type,
        :start_date,
        :end_date,
        :employee_name,
        :employee_position,
        :employee_email_address,
        :employee_department,
        :employee_phone,
        :employee_access,
        :entity_source,
        :fingerprint_business_area,
        :fingerprint_business_operations,
        :fingerprint_it_operations,
        :fingerprint_server_room,
        :fingerprint_archive_room,
        :fingerprint_engineering_area,
        :corporate_email,
        :internet_access,
        :slack_access,
        :admin_tools,
        :vpn_access,
        :github_gitlab,
        :exit_interview,
        :access_card,
        :parking_cards,
        :id_card,
        :name_card,
        :insurance_card,
        :cash_advance,
        :password_reset,
        :user_identification,
        :asset_name,
        :production_access,
        :production_user_id,
        :production_asset,
        :business_justification,
        :metabase,
        :solutions_dashboard,
        :vision_access,
        :approver_ids => [],
        :collaborator_ids => []
    ).tap do |params|
      normalized_array_fields = [:approver_ids, :collaborator_ids]
      normalized_array_fields.each do |field|
        params[field].select!{ |id| id.present? }.map!{ |id| id.to_i} if params[field].present?
      end
    end
  end

  def set_access_request_reason
    @access_request.reason = params[:access_request_status][:reason]
  end

  def set_users_and_approvers
    @users = User.active.collect{|u| [u.name, u.id] }
    @approvers = User.approvers_ar.active.collect{|u| [u.name, u.id] if u.id != current_user.id }
  end

  def set_access_request_approval
    @approval = AccessRequestApproval.find_by(access_request_id: @access_request.id, user_id: current_user.id)
    unless @approval
      flash[:alert] = 'You are not eligible to approve this Access Request'
      redirect_to @access_request
    end
  end

  def authorized_to_change_status
    unless @access_request.actionable?(current_user)
      flash[:alert] = 'You are not eligible to change the status of this Access Request'
      redirect_to @access_request
    end
  end
end
