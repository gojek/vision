class ChangeRequestsController < ApplicationController
  before_action :set_change_request, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!
  before_action :owner_required, only: [:edit, :update, :destroy]

  # GET /change_requests
  # GET /change_requests.json
  def index
    @change_requests = ChangeRequest.all
  end

  # GET /change_requests/1
  # GET /change_requests/1.json
  def show
  end

  # GET /change_requests/new
  def new
    @change_request = ChangeRequest.new
  end

  # GET /change_requests/1/edit
  def edit
  end

  # POST /change_requests
  # POST /change_requests.json
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

  # PATCH/PUT /change_requests/1
  # PATCH/PUT /change_requests/1.json
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

  # DELETE /change_requests/1
  # DELETE /change_requests/1.json
  def destroy
    @change_request.destroy
    respond_to do |format|
      format.html { redirect_to change_requests_url, notice: 'Change request was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_change_request
      @change_request = ChangeRequest.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def change_request_params
      params.require(:change_request).permit(:requestor_desc, :priority, :category, :cr_type, :change_requirement, :business_justification, :requestor_position, :note, :analysis, :solution, :impact, :scope, :design, :backup, :restore, :testing_environment_available, :testing_procedure, :testing_notes, :schedule_change_date, :planned_completion, :grace_period_starts, :grace_period_end, :implementation_notes, :grace_period_notes, 
        implementers_attributes: [ :name, :position ], testers_attributes: [ :name, :position], cabs_attributes: [:name, :position, :reason, :approve], approvals_attributes: [:name, :position])
    end

    def owner_required
      redirect_to change_requests_url if
      current_user != @change_request.user && current_user.role != 'admin'
  end
end
