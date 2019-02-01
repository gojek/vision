#
class IncidentReportsController < ApplicationController

  before_action :set_incident_report, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!
  before_action :owner_required, only: [:edit, :update, :destroy]
  before_action :set_source_start_end_time, only: [:total_incident_per_level, :average_recovery_time_incident]
  before_action :set_users_and_tags, only: [:new, :create, :edit, :update]
  before_action :set_incident_report_log, only: [:update]
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
      format.csv do
        if params[:page].present?
          # download current page only
          render csv: @incident_reports, filename: 'incident_reports', force_quotes: true
        else
          enumerator = Enumerator.new do |lines|
            lines << IncidentReport.to_comma_headers.to_csv
            IncidentReport.find_each do |record|
              lines << record.to_comma.to_csv
            end
          end
          self.stream('incident_reports_all.csv', 'text/csv', enumerator)
        end
      end
      format.xls { send_data(@incident_reports.to_xls) }
    end

  end

  def show
    @incident_report.mark_as_read! :for => current_user
    Notifier.ir_read(current_user,@incident_report)
    unless @incident_report.action_item.nil?
      @action_item = Jira.new.jiraize(@incident_report.action_item)
    end
  end

  def new
    @incident_report = IncidentReport.new
    @current_tags = []
  end

  def edit
    @current_tags = @incident_report.tag_list
  end

  def create
    @incident_report = current_user.IncidentReports.build(incident_report_params)
    respond_to do |format|
      if @incident_report.save
        flash[:success] = 'Incident report was successfully created.'
        format.html { redirect_to @incident_report }
        format.json { render :show, status: :created, location: @incident_report }
        Notifier.ir_notify(current_user, @incident_report, 'new_ir')
        SlackNotif.new.notify_new_ir @incident_report
      else
        @tags = ActsAsTaggableOn::Tag.all.collect(&:name)
        @current_tags = []
        format.html { render :new }
        format.json { render json: @incident_report.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @current_collaborators = Array.wrap(params[:collaborators_list])
    @incident_report.set_collaborators(@current_collaborators)

    respond_to do |format|
      if @incident_report.update(incident_report_params)

        if @incident_report.check_status
          Notifier.ir_notify(current_user, @incident_report, 'resolved_ir')
        end

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
      flash[:alert] = 'Incident report was successfully destroyed.'
      format.html { redirect_to incident_reports_url }
      format.json { head :no_content }
    end
  end

  def deleted
    @incident_reports = IncidentReportVersion.where(event: 'destroy')
                        .page(params[:page]).per(params[:per_page])
  end

  def search
    if params[:search].blank?
      redirect_to incident_reports_path
    else
      @search = IncidentReport.solr_search do
        fulltext params[:search], highlight: true
        order_by(:created_at, :desc)
        paginate page: params[:page] || 1, per_page: params[:per_page] || 20
      end
      respond_to do |format|
        format.html
        format.csv do
          if params[:page].present?
            # download current page only
            ids = []
            @search.hits.each do |hit|
              ids << hit.primary_key
            end
            incident_reports = IncidentReport.where(id: ids)
            render csv: incident_reports, filename: 'incident_reports', force_quotes: true
          else
            # download all page through sucker punch
            email = current_user.email
            IncidentReportJob.perform_async(IncidentReport.ids, email)
            redirect_to incident_reports_path, notice: "CSV is being sent to #{email}"
          end
        end
      end
    end
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
  def incident_reports_by_recovery_resolved_duration
    start_month = (Time.now).beginning_of_month
    end_month = (Time.now).end_of_month
    if params[:start_time]
      start_month = Time.parse(params[:start_time])
      end_month = start_month.end_of_month
    end
    i = 1
    result = []
    title = start_month.strftime('%Y/%m')
    while start_month <= end_month do
      start_time = start_month
      if start_month.end_of_week > start_month.end_of_month
        end_time = end_month
      else
        end_time = start_month.end_of_week
      end
      acknowledge = IncidentReport.where('time_to_acknowledge_duration > 0 AND acknowledge_time <= ? AND acknowledge_time >= ?', end_time, start_time)
      resolved = IncidentReport.where('recovery_duration > 0 AND resolved_time <= ? AND resolved_time >= ?', end_time, start_time)

      avg_acknowledge = recovery.blank? ? 0 : acknowledge.average(:time_to_acknowledge_duration)
      avg_resolved = resolved.blank? ? 0 : resolved.average(:recovery_duration)
      result << {
        label: start_time.strftime("%d/%m")+' - '+end_time.strftime("%d/%m"),
        recovery_duration: avg_acknowledge,
        resolution_duration: avg_resolved
      }
      i = i+1
      start_month = (start_month.end_of_week + 1.day).beginning_of_day
    end

    final_result = [{title: title}, result]
    render :text => final_result.to_json
  end


  respond_to :json
  def incident_reports_internal_external
    if params[:end_time]
      current = Time.parse(params[:end_time])
    else
      current = Date.current
    end

    start_month = (current - 6.months).beginning_of_month
    end_month = current.end_of_month

    title = start_month.strftime("%B %Y") + ' - ' + end_month.strftime("%B %Y")

    irs = IncidentReport.group_by_month(:occurrence_time, format: "%b %Y", range: start_month..end_month)
    internals = irs.where(source: 'Internal').count
    results = irs.where(source: 'External').count
      .map { |k,x| { label: k, total_internal: internals[k], total_external: x  } }

    final_result = [{title: title}, results]
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
      recovered = IncidentReport.where("acknowledge_time <= ? AND acknowledge_time >= ?", end_time, start_time)
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

  def total_incident_per_level
    irs = IncidentReport.group_by_week(:occurrence_time, range: @start_time..@end_time).where(source: @source)

    ranks = 1..5
    totals = {}
    ranks.each do |rank|
      totals[rank] = irs.where(rank: rank).count
    end

    results = []
    totals.first.last.each do |k, x|
      current = {}
      current[:label] = "#{k.strftime("%d/%m")} - #{(k + 6.day).strftime("%d/%m")}"
      ranks.each do |rank|
        current["Level #{rank}"] = totals[rank][k]
      end
      results << current
    end

    final_result = [{title: "Total #{@source} Incident Per Level"}, results]
    render :text => final_result.to_json
  end

  def average_recovery_time_incident
    irs = IncidentReport.group_by_week(:occurrence_time, range: @start_time..@end_time).where(source: @source)

    count = irs.count
    detection_duration_sum = irs.sum('extract(epoch from detection_time - occurrence_time)')
    fixing_duration_sum = irs.sum('extract(epoch from resolved_time - detection_time)')
    results = fixing_duration_sum.map do |k, v|
      n = [count[k], 1].max
      {
        label: "#{k.strftime("%d/%m")} - #{(k + 6.day).strftime("%d/%m")}",
        detection: '%.2f' % ((detection_duration_sum[k] / n) / 60),
        fixing: '%.2f' % ((v / n) / 60)
      }
    end

    final_result = [{title: "Average Recovery Time Duration for #{@source} Incident"}, results]
    render :text => final_result.to_json
  end


  private

  def set_incident_report
    @incident_report = IncidentReport.find(params[:id])
  end

  def set_incident_report_log
    @incident_report.editor = current_user
    @incident_report.reason = params[:incident_report][:reason]
  end

  def incident_report_params
    params.require(:incident_report)
      .permit(:service_impact, :expected, :problem_details, :how_detected,
              :occurrence_time, :detection_time, :acknowledge_time,:resolved_time,
              :source, :rank, :loss_related, :occurred_reason,
              :overlooked_reason, :solving_duration, :recovery_action, :prevent_action,
              :recurrence_concern, :current_status, :measurer_status, :has_further_action,
              :action_item, :action_item_status, :tag_list => [])
  end

  def owner_required
    redirect_to incident_reports_url if !(@incident_report.editable? current_user)
  end

  def set_users_and_tags
    @users = User.active.collect{|u| [u.name, u.id] }
    @tags = ActsAsTaggableOn::Tag.all.collect(&:name)
  end

end
