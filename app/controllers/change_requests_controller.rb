class ChangeRequestsController < ApplicationController
  before_action :set_change_request, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!
  before_action :owner_required, only: [:edit, :update, :destroy]

  def index
    @change_requests = ChangeRequest.order(created_at: :desc).page(params[:page]).per(params[:per_page])
  end

  def show
  end

  def new
    @change_request = ChangeRequest.new
  end

  def edit
  end

  def create
    @change_request = current_user.ChangeRequests.build(change_request_params)
    respond_to do |format|
      if @change_request.save
        format.html { redirect_to @change_request, notice: 'Change request was successfully created.' }
        format.json { render :show, status: :created, location: @change_request }
      else
        format.html { render :new }
        format.json { render json: @change_request.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @change_request.update(change_request_params)
        format.html { redirect_to @change_request, notice: 'Change request was successfully updated.' }
        format.json { render :show, status: :ok, location: @change_request }
      else
        format.html { render :edit }
        format.json { render json: @change_request.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @change_request.destroy
    respond_to do |format|
      format.html { redirect_to change_requests_url, notice: 'Change request was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    def set_change_request
      @change_request = ChangeRequest.find(params[:id])
    end

    def change_request_params
      params.require(:change_request).permit(:change_summary, :priority, :db, :os, :net, :category, :cr_type, :change_requirement, :business_justification, :requestor_position, :note, :analysis, :solution, :impact, :scope, :design, :backup,:testing_environment_available, :testing_procedure, :testing_notes, :schedule_change_date, :planned_completion, :grace_period_starts, :grace_period_end, :implementation_notes, :grace_period_notes, 
        implementers_attributes: [ :name, :position ], testers_attributes: [ :name, :position], cabs_attributes: [:name, :position, :reason, :approve], approvals_attributes: [:name, :position])
    end

    def owner_required
      redirect_to change_requests_url if
      current_user != @change_request.user && current_user.role != 'admin'
  end
end
