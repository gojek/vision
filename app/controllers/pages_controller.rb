class PagesController < ApplicationController
before_action :authenticate_user!

  def index
  	@recovered = IncidentReport.where(current_status: 'Recovered').count
  	@ongoing = IncidentReport.where(current_status: 'Ongoing').count
  	@implemented = IncidentReport.where(measurer_status: 'Implemented').count
  	@development = IncidentReport.where(measurer_status: 'Development').count
  end

end
