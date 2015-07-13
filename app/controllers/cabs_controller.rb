class CabsController < ApplicationController
	before_action :set_cab, only: [:edit, :update, :show, :destroy]
  
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
		@cr_list = params[:cr_list].split(",")
		@cab.save
		ChangeRequest.where(:id => @cr_list).update_all(:cab_id => @cab.id)
		redirect_to @cab
	end

  def destroy
    @cab.destroy
    redirect_to cabs_url
  end

	def edit
		@change_requests = ChangeRequest.cab_free
		@current_change_requests = ChangeRequest.where(:cab_id => @cab.id)
	end

	def update
    @cab.update(cab_params)
    @cr_list = params[:cr_list].split(",")
    @all_cr_list = params[:all_cr_list].split(",")
    ChangeRequest.where(:id => @cr_list).update_all(:cab_id => @cab.id)
    ChangeRequest.where(:id => @all_cr_list).update_all(:cab_id => nil)
    redirect_to @cab
	end

  def show
    @current_change_requests = ChangeRequest.where(:cab_id => @cab.id)
  end

	private

	def cab_params
		params.require(:cab).permit(:meet_date, :cr_list, :all_cr_list)
	end

  def set_cab
    @cab = Cab.find(params[:id])
  end

end
