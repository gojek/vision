#
class VersionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_document_and_version, only: [:diff, :rollback, :destroy]

  def diff
  end

  def rollback
    # change the current document to the specified version
    # reify gives you the object of this version
    incident_report = @version.reify
    incident_report.save
    redirect_to edit_incident_report_path(incident_report)
  end

  def bringback
    version = IncidentReportVersion.find(params[:id])
    @incident_report = version.reify
    @incident_report.save
    # Let's remove the version since the document is undeleted
    version.delete
    redirect_to incident_reports_path,
                notice: 'The document was successfully brought back!'
  end

  private

  def set_document_and_version
    @incident_report = IncidentReport.find(params[:incident_report_id])
    @version = @incident_report.versions.find(params[:id])
  end
end
