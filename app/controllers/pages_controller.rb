#
class PagesController < ApplicationController
  before_action :signed_in, only: [:index]

  def index
    @recovered = IncidentReport.where(current_status: 'Recovered').count
    @ongoing = IncidentReport.where(current_status: 'Ongoing').count
    @implemented = IncidentReport.where(measurer_status: 'Implemented').count
    @development = IncidentReport.where(measurer_status: 'Development').count
  end
  def blank
  end

  def signin
    redirect_to root_path if user_signed_in?
  end

  private

  def signed_in
    redirect_to signin_path unless user_signed_in?
  end
end
