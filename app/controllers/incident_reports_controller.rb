#
class IncidentReportsController < ApplicationController
  before_action :set_incident_report, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!
  before_action :owner_required, only: [:edit, :update, :destroy]

  def index
    if params[:tag]
      @q = IncidentReport.ransack(params[:q])
      @incident_reports = @q.result(distinct: true).tagged_with(params[:tag]).page(params[:page]).per(params[:per_page])
    else
      @q = IncidentReport.ransack(params[:q])
      @incident_reports = @q.result(distinct: true).page(params[:page]).per(params[:per_page])
    end
    respond_to do |format|
      format.html
      format.xls { send_data(@incident_reports.to_xls) }
    end
  end

  def show
  end

  def new
    @incident_report = IncidentReport.new
    @tags = ActsAsTaggableOn::Tag.all.collect(&:name)
    @current_tags = []
  end

  def edit
    @tags = ActsAsTaggableOn::Tag.all.collect(&:name)
    @current_tags = @incident_report.tag_list
  end

  def create
    @incident_report = current_user.IncidentReports.build(incident_report_params)
    @incident_report.recovery_duration = (@incident_report.recovery_time - @incident_report.occurrence_time)/60
    (@incident_report.resolved_time)?    @incident_report.resolution_duration = (@incident_report.resolved_time - @incident_report.occurrence_time)/60 : 0
 
    respond_to do |format|
      if @incident_report.save
        flash[:create_incident_report_notice] = 'Incident report was successfully created.'
        format.html { redirect_to @incident_report }
        format.json { render :show, status: :created, location: @incident_report }
      else
        @tags = ActsAsTaggableOn::Tag.all.collect(&:name)
        @current_tags = []
        format.html { render :new }
        format.json { render json: @incident_report.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
   
    respond_to do |format|
      if @incident_report.update(incident_report_params)
        @incident_report.recovery_duration = (@incident_report.recovery_time - @incident_report.occurrence_time)/60
        (@incident_report.resolved_time)?    @incident_report.resolution_duration = (@incident_report.resolved_time - @incident_report.occurrence_time)/60 : 0
        @incident_report.save
        flash[:update_incident_report_notice] = 'Incident report was successfully updated.' 
        format.html { redirect_to @incident_report }
        format.json { render :show, status: :ok, location: @incident_report }
      else
        @tags = ActsAsTaggableOn::Tag.all.collect(&:name)
        @current_tags = @incident_report.tag_list
        format.html { render :edit }
        format.json { render json: @incident_report.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @incident_report.destroy
    respond_to do |format|
      flash[:destroy_incident_report_notice] = 'Incident report was successfully destroyed.'
      format.html { redirect_to incident_reports_url }
      format.json { head :no_content }
    end
  end

  def deleted
    @incident_reports = IncidentReportVersion.where(event: 'destroy')
                        .page(params[:page]).per(params[:per_page])
  end

  private

  def set_incident_report
    @incident_report = IncidentReport.find(params[:id])
  end

  def incident_report_params
    params.require(:incident_report)
      .permit(:service_impact, :problem_details, :how_detected,
              :occurrence_time, :detection_time, :recovery_time,:resolved_time,
              :source, :rank, :loss_related, :occurred_reason,
              :overlooked_reason, :solving_duration, :recovery_action, :prevent_action,
              :recurrence_concern, :current_status, :measurer_status, :tag_list => [])
  end

  def owner_required
    redirect_to incident_reports_url if
    current_user != @incident_report.user && !current_user.is_admin
  end
end
