#
class IncidentReportsController < ApplicationController

  before_action :set_incident_report, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!
  before_action :owner_required, only: [:edit, :update, :destroy]
require 'notifier.rb'
  def index
    if params[:tag]
      @q = IncidentReport.ransack(params[:q])
      @incident_reports = @q.result(distinct: true).tagged_with(params[:tag]).order(id: :desc).page(params[:page]).per(params[:per_page])
    elsif params[:tag_list]
      @q = IncidentReport.ransack(params[:q])
      @incident_reports = @q.result(distinct: true).tagged_with(params[:tag_list]).order(id: :desc).page(params[:page]).per(params[:per_page])
    else
      @q = IncidentReport.ransack(params[:q])
      @incident_reports = @q.result(distinct: true).page(params[:page]).order(id: :desc).per(params[:per_page])
    end

    @tags = ActsAsTaggableOn::Tag.all.collect(&:name)
    respond_to do |format|
      format.html
      format.xls { send_data(@incident_reports.to_xls) }
    end

  end

  def show
     @incident_report.mark_as_read! :for => current_user
     Notifier.ir_read(current_user,@incident_report)
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
    @incident_report.recovery_duration = (@incident_report.recovery_time)? (@incident_report.recovery_time - @incident_report.occurrence_time)/60 : 0
    @incident_report.resolution_duration = (@incident_report.resolved_time)? (@incident_report.resolved_time - @incident_report.occurrence_time)/60 : 0
    @incident_report.set_current_status
    respond_to do |format|
      if @incident_report.save
        flash[:success] = 'Incident report was successfully created.'
        format.html { redirect_to @incident_report }
        format.json { render :show, status: :created, location: @incident_report }
         Notifier.ir_notify(current_user, @incident_report, 'new_ir')
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
        
        (@incident_report.recovery_time)? @incident_report.recovery_duration = (@incident_report.recovery_time - @incident_report.occurrence_time)/60 : 0
        (@incident_report.resolved_time)? @incident_report.resolution_duration = (@incident_report.resolved_time - @incident_report.occurrence_time)/60 : 0
        @incident_report.set_current_status
        if @incident_report.check_status
          Notifier.ir_notify(current_user, @incident_report, 'resolved_ir')
        end
        @incident_report.save

        flash[:success] = 'Incident report was successfully updated.' 
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
      flash[:success] = 'Incident report was successfully destroyed.'
      format.html { redirect_to incident_reports_url }
      format.json { head :no_content }
    end
  end

  def deleted
    @incident_reports = IncidentReportVersion.where(event: 'destroy')
                        .page(params[:page]).per(params[:per_page])
  end

  respond_to :json
  def incident_reports_by_source()
    #default is per week
    title = 'This Week'
    start_time = Time.now.beginning_of_week
    end_time = Time.now.end_of_week

    if params[:month]
      title = 'This Month'
      start_time = Time.now.beginning_of_month
      end_time = Time.now.end_of_month
    end

    if params[:start_time]
      title = params[:start_time]
      start_time = (params[:start_time].in_time_zone('Asia/Jakarta'))
    end
    if params[:end_time]
      title = title + ' - ' + params[:end_time]
      end_time = (params[:end_time].in_time_zone('Asia/Jakarta'))
    end
    
    internal = IncidentReport.where("occurrence_time <= ? AND occurrence_time >= ? AND source = 'Internal'", end_time, start_time).count
    external = IncidentReport.where("occurrence_time <= ? AND occurrence_time >= ? AND source = 'External'", end_time, start_time).count
    pieData = [
        {
          title: "Internal",
          value: internal
          
        },
        {
          title: "External",
          value: external
        }
      ]
    final_result = [{title: title}, pieData]
    render :text => final_result.to_json   
  end


  respond_to :json
  def incident_reports_by_recovered_resolved_duration
    start_month = (Time.now).beginning_of_month
    end_month = (Time.now).end_of_month
    if params[:start_time]
      start_month = Time.parse(params[:start_time])
      end_month = start_month.end_of_month
    end
    i = 1
    avg_recovery_data = []
    avg_resolved_data = []
    result = []
    title = start_month.strftime('%Y/%m')
    while start_month <= end_month do
      start_time = start_month
      if start_month.end_of_week > start_month.end_of_month
        end_time = end_month
      else
        end_time = start_month.end_of_week
      end
      recovery = IncidentReport.where('recovery_duration > 0 AND recovery_time <= ? AND recovery_time >= ?', end_time, start_time)
      resolved = IncidentReport.where('resolution_duration > 0 AND resolved_time <= ? AND resolved_time >= ?', end_time, start_time)
      
      avg_recovery = recovery.blank? ? 0 : recovery.average(:recovery_duration)
      avg_resolved = resolved.blank? ? 0 : resolved.average(:resolution_duration)
      result << { 
        label: start_time.strftime("%d/%m")+' - '+end_time.strftime("%d/%m"),
        recovery_duration: avg_recovery,
        resolution_duration: avg_resolved
      }
      i = i+1
      #result << {:start => start_time, :end => end_time}
      start_month = (start_month.end_of_week + 1.day).beginning_of_day
    end
    
    final_result = [{title: title}, result]
    render :text => final_result.to_json
  end

  respond_to :json
  def incident_reports_number
    start_month = (Time.now).beginning_of_month
    end_month = (Time.now).end_of_month
    if params[:start_time]
      start_month = Time.parse(params[:start_time])
      end_month = start_month.end_of_month
    end
    i = 1
    #avg_recovery_data = []
    #avg_resolved_data = []
    result = []
    title = start_month.strftime('%Y/%m')
    while start_month <= end_month do
      start_time = start_month
      if start_month.end_of_week > start_month.end_of_month
        end_time = end_month
      else
        end_time = start_month.end_of_week
      end
      occured = IncidentReport.where("occurrence_time <= ? AND occurrence_time >= ?", end_time, start_time)
      recovered = IncidentReport.where("recovery_time <= ? AND recovery_time >= ?", end_time, start_time)
      resolved = IncidentReport.where("resolved_time <= ? AND resolved_time >= ?", end_time, start_time)
      
      total_occured = occured.blank? ? 0 : occured.count
      total_recovered = recovered.blank? ? 0 : recovered.count
      total_resolved = resolved.blank? ? 0 : resolved.count
      result << { 
        label: start_time.strftime("%d/%m")+' - '+end_time.strftime("%d/%m"),
        occured_number: total_occured,
        recovered_number: total_recovered,
        resolved_number: total_resolved
      }
      i = i+1
      #result << {:start => start_time, :end => end_time}
      start_month = (start_month.end_of_week + 1.day).beginning_of_day
    end

    final_result = [{title: title}, result]
    render :text => final_result.to_json
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
