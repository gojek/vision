#
class PagesController < ApplicationController
before_action :signed_in, only: [:index]

  def index
  	@recovered = IncidentReport.where(current_status: 'Recovered').count
  	@ongoing = IncidentReport.where(current_status: 'Ongoing').count
  	@implemented = IncidentReport.where(measurer_status: 'Implemented').count
  	@development = IncidentReport.where(measurer_status: 'Development').count
  end

  def signin
  	unless !user_signed_in?
  		redirect_to root_path
  	end
  end

  private
  def signed_in
  	unless user_signed_in?
  		redirect_to signin_path
  	end
  end
end
