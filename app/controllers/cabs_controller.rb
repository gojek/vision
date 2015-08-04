class CabsController < ApplicationController
  before_action :authenticate_user!
	before_action :set_cab, only: [:edit, :update, :show, :destroy]
  before_action :release_manager_required

  
  def index
    @q = Cab.ransack(params[:q])
    @cabs = @q.result(distinct: true).order(meet_date: :desc).page(params[:page]).per(params[:per_page])
  end
	
  def new 
		@change_requests =ChangeRequest.cab_free
		@cab = Cab.new
	end
	
	def create
		@cab = Cab.new(cab_params)
		if @cab.save
      @cr_list = params[:cr_list].split(",")
		  ChangeRequest.where(:id => @cr_list).update_all(:cab_id => @cab.id)
      UserMailer.cab_email(@cab).deliver_later
      #SendCabEmailJob.set(wait: 20.seconds).perform_later(@cab)
      flash[:create_cab_notice] = 'CAB successfully arranged'
		  redirect_to @cab
    else
      @change_requests =ChangeRequest.cab_free
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
	end

	def update
    if @cab.update(cab_params)
      @cr_list = params[:cr_list].split(",")
      @all_cr_list = params[:all_cr_list].split(",")
      ChangeRequest.where(:id => @cr_list).update_all(:cab_id => @cab.id)
      ChangeRequest.where(:id => @all_cr_list).update_all(:cab_id => nil)
      flash[:update_cab_notice] = 'CAB successfully edited'
      redirect_to @cab
    else
      @change_requests = ChangeRequest.cab_free
      @current_change_requests = ChangeRequest.where(:cab_id => @cab.id)
      render :edit
    end
	end

  def show
    @current_change_requests = ChangeRequest.where(:cab_id => @cab.id)
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

	private

  def release_manager_required
    redirect_to root_path unless current_user.role == 'release_manager' || current_user.is_admin
  end

	def cab_params
		params.require(:cab).permit(:meet_date, :cr_list, :all_cr_list, :room, :notes)
	end

  def set_cab
    @cab = Cab.find(params[:id])
  end

end
