class CabsController < ApplicationController
  before_action :authenticate_user!
	before_action :set_cab, only: [:edit, :update, :show, :destroy, :get_change_requests, :update_change_requests]
  before_action :authorized_user_required, only:[:create, :edit, :update, :destroy, :arrange_google_calendar, :update_change_requests, :new]

  def index
    @q = Cab.ransack(params[:q])
    @cabs = @q.result(distinct: true).order(meet_date: :desc).page(params[:page]).per(params[:per_page])
  end
	
  def new 
		@change_requests =ChangeRequest.cab_free
		@cab = Cab.new
    @participants = Cab::PARTICIPANTS + current_user.get_contacts
	end
	
	def create
		@cab = Cab.new(cab_params)
    @participants = cab_params[:participant]
    @cab.participant = (@participants.reject { |c| c.empty? }).join(',')
		if @cab.save
      @cr_list = params[:cr_list].split(",")
		  ChangeRequest.where(:id => @cr_list).update_all(:cab_id => @cab.id)
      Thread.new do
        UserMailer.cab_email(@cab).deliver
        ActiveRecord::Base.connection.close
      end
      flash[:create_cab_notice] = 'CAB successfully arranged'      
      arrange_google_calendar
		  redirect_to @cab
    else
      @change_requests =ChangeRequest.cab_free
      @participants = Cab::PARTICIPANTS + current_user.get_contacts
      render :new
    end
	end

  def destroy
    @cab.destroy
    flash[:destroy_cab_notice] = 'CAB successfully destroyed'
    redirect_to cabs_url
  end

	def edit
		@change_requests = ChangeRequest.cab_free
		@current_change_requests = ChangeRequest.where(:cab_id => @cab.id)
    @current_participants = @cab.participant.split(',')
    @participants = Cab::PARTICIPANTS + current_user.get_contacts + @current_participants
    @participants = @participants.uniq
	end

	def update
    @participants = cab_params[:participant]
    if @cab.update(cab_params)
      #change participant from array to string
      @cab.participant = (@participants.reject { |c| c.empty? }).join(',')
      @cab.save
      @cr_list = params[:cr_list].split(",")
      @all_cr_list = params[:all_cr_list].split(",")
      ChangeRequest.where(:id => @cr_list).update_all(:cab_id => @cab.id)
      ChangeRequest.where(:id => @all_cr_list).update_all(:cab_id => nil)
      flash[:update_cab_notice] = 'CAB successfully edited'
      redirect_to @cab
    else
      @change_requests = ChangeRequest.cab_free
      @current_change_requests = ChangeRequest.where(:cab_id => @cab.id)
      @current_participants = @cab.participant.split(',')
      @participants = Cab::PARTICIPANTS + current_user.get_contacts + @current_participants
      @participants = @participants.uniq
      render :edit
    end
	end

  def show
    @current_change_requests = ChangeRequest.where(:cab_id => @cab.id)
  end

  def arrange_google_calendar
    attendees = []
    @participants.each do |participant|
      attendees.push({'email' => participant}) unless participant.blank? 
    end
    event = {
      'summary' => 'CAB Meeting',
      'location' => @cab.room,
      'description' => @cab.notes,
      'start' => {
        'dateTime' => @cab.meet_date.iso8601,
        'timeZone' => 'Asia/Jakarta',
      },
      'end' => {
        'dateTime' => (@cab.meet_date+1.hour).iso8601,
        'timeZone' => 'Asia/Jakarta',
      },
      'attendees' => attendees
    }

    client = Google::APIClient.new
    client.authorization.access_token = current_user.fresh_token
    service = client.discovered_api('calendar', 'v3')
    results = client.execute!(
      :api_method => service.events.insert,
      :parameters => {
        :calendarId => 'primary', :sendNotifications => 'true'},
      :body_object => event)
    event = results.data
  end


  def update_change_requests
    change_requests = @cab.change_requests
    change_requests.each do |change_request|
      start_date = params['start'+change_request.id.to_s]
      end_date = params['end'+change_request.id.to_s]
      change_request.planned_completion = end_date
      change_request.schedule_change_date = start_date
      change_request.save
    end
    redirect_to @cab

  end

  respond_to :json
  def get_cabs
    @cabs = Cab.all
    events = []
    @cabs.each do |cab|
      events << {:id => cab.id, :title => "CAB #{cab.id}", :start => "#{cab.meet_date.to_time.iso8601}", :end => "#{cab.meet_date.to_time.iso8601}",
                 :url => "#{url_for(cab)}"}      
    end
    render :text => events.to_json
  end

  respond_to :json
  def get_change_requests
    @change_requests = @cab.change_requests
    events =[]
    @change_requests.each do |change_request|
      events << {:id => change_request.id, :title => change_request.change_summary, :start => "#{change_request.schedule_change_date.to_time.iso8601}", 
                 :end => "#{change_request.planned_completion.to_time.iso8601}"}
    end
    render :text => events.to_json
  end

	private

  def authorized_user_required
    redirect_to root_path unless current_user.role == 'release_manager' || current_user.is_admin
  end

	def cab_params
		params.require(:cab).permit(:meet_date, :cr_list, :all_cr_list, :room, :notes, :participant => [])
	end

  def set_cab
    @cab = Cab.find(params[:id])
  end

end
