class Fcg::HomeController < ApplicationController
	before_filter :authenticate_user!
  helper_method :sort_column, :sort_direction

  # Show all care clients and perform searching sorting among them.
  def view_care_clients
    if current_care_giver_company
      @care_clients = current_care_giver_company.care_clients.list_care_clients(params[:search],sort_column,sort_direction,params[:page])
    end
  end
	
  #Retrieve Care Givers of a particular Care Client
	def get_care_givers
  	render text: "Successfully retrieved Home Health Aides of this care client!!!" and return
  end

  # Add New CareClient
  # GET /fcg/home/new
  def new
  	@care_client = CareClient.new
    # authorize @care_client
    @care_client.build_user
  end

  # Create New CareClient with role
  # POST /fcg/home
  def create
    password = Devise.friendly_token.first(8)
    params[:care_client][:user_attributes][:password] = password rescue nil
    params[:care_client][:dob] = formatted_date(params[:care_client][:dob])
    @care_client = CareClient.new(fcg_params)
    if @care_client.register(params, current_user.care_giver_company.id)
      redirect_to fcg_view_care_clients_path
    else
      render 'new'
    end
  end

  # Changing status of care client.
  def change_status
    @status = params[:status]
    @care_client = CareClient.find(params[:id])
    authorize @care_client
    @care_client.status_change(params[:status])
    redirect_to  fcg_view_care_clients_path(page: params[:page])
  end

  # Deleting care client and their associated data.
  def delete_care_client
     @care_client = CareClient.find(params[:id])
     authorize @care_client
     @care_client.destroy
     redirect_to fcg_view_care_clients_path
  end

  # Launching edit page of care client.
  def edit
    @care_client_current = CareClient.find(params[:id])
    authorize @care_client_current
    @care_client = current_user.care_giver_company.care_clients if current_user.has_role? :pcga
    authorize @care_client_current
  end


  # Updating the care client after editing.
  def update
    @care_client = CareClient.find(params[:id])
    params[:care_client][:dob] = formatted_date(params[:care_client][:dob]) if params[:care_client][:dob]
    @care_client.update_attributes(fcg_params)
    redirect_to edit_fcg_home_path
  end


  # For customizing service plan of a care giver company.
  def custamise_service_plan
    if current_care_giver_company && current_care_giver_company.care_clients.present?
      @care_clients = current_care_giver_company.active_care_clients
      @current_care_client = CareClient.find_by_id(params[:care_client_id])
      @categories = ServiceCategory.includes(:services).where(:care_giver_company_id => current_care_giver_company.id)
      @data = CareClientsService.where(care_giver_company_id: current_care_giver_company.id, care_client_id: params[:care_client_id]).all
    end
  end


  # Saving services for a care client.
  def save_care_client_services
    params[:contents].each do |content|
      @service_id = content.to_s.split('_')[0].to_i
      @option = content.to_s.split('_')[1].to_s
      @item = CareClientsService.where(service_id: @service_id, care_client_id: params[:care_client_id]).first
      unless @item.present?
        CareClientsService.create(care_client_id: params[:care_client_id], service_id: @service_id, option: @option, care_giver_company_id: current_care_giver_company.id)
      else
        @item.update_attributes(care_client_id: params[:care_client_id], service_id: @service_id, option: @option, care_giver_company_id: current_care_giver_company.id)
      end
    end
    render :json => {data: "success"}
  end

  def view_services
    @care_client = CareClient.includes(:services => [:care_clients_services, :service_category]).find(params[:id])
    @services = @care_client.get_services(3)
    authorize @care_client
  end

  private

  #FCG Params
  def fcg_params
    params.require(:care_client).permit(:first_name,
																				:last_name,
																				:gender,
																				:dob,
																				:telephone,
																				:password,
																				:mobile_no,
																				:time_zone,
																				:country_id,
																				:address_1,
																				:address_2,
																				:state_id,
																				:city,
																				:zip,
																				:telephony_no,
																				:last_name,
                                        :medical_record_number,
      																	{:user_attributes => [:email,:password]})
  end


  # Allows only column names as sort parameter and "status" as the default parameter.
  def sort_column
    # CareClient.column_names.include?(params[:sort]) ? params[:sort] : "status"
    ["last_name","first_name","city","telephone","status","care_givers"].include?(params[:sort]) ? params[:sort] : "status"
  end


  # Allows only "asc" and "dsc" sort direction parameter.
  def sort_direction
    %w[asc desc].include?(params[:direction]) ?  params[:direction] : "asc"
  end

end
