class Pcg::HomeController < ApplicationController
  before_filter :authenticate_user!
  helper_method :sort_column, :sort_direction, :sort_column_event
  # Add New PCG
  # GET /pcg/home/new
  def new
    @care_giver = CareGiver.new
    authorize @care_giver
    @care_giver.build_user
  end

  # Create New PCG with role
  # POST /pcg/home
  def create
    password = Devise.friendly_token.first(8)
    params[:care_giver][:user_attributes][:password] =password rescue nil
    @care_giver = current_care_giver_company.care_givers.build(pcg_params)
    authorize @care_giver
    if @care_giver.save
      @care_giver.user.add_role :pcg
      redirect_to pcga_home_index_path
    else
      render @care_giver.errors.full_messages
    end
  end


  # Channging the status of care giver.
  def change_status
    @care_giver = CareGiver.find(params[:id])
    authorize @care_giver
    @care_giver.change_status
    redirect_to pcga_home_index_path(page: params[:page])
  end

  # get address for mr code
  def get_address
    @care_client = CareClient.find(params[:care_client_id])
  end


  # Deletes care giver.
  def delete_care_giver
    @care_giver = CareGiver.find(params[:id])
    authorize @care_giver
    @care_giver.destroy
    redirect_to pcga_home_index_path
  end

  # For editing the care giver details.
  def edit
    @care_giver_current = CareGiver.find(params[:id])
    @care_giver = current_user.care_giver_company.care_givers if current_user.has_role? :pcga
    authorize @care_giver_current
  end

   # Update PCG Details
   # PATCH /pcg/home/:id
   def update
     @care_giver = CareGiver.find(params[:id])
     params[:care_giver][:dob] = formatted_date(params[:care_giver][:dob]) if params[:care_giver][:dob]
     @care_giver.update_attributes(pcg_params)
     if current_user.has_role? :pcg
       redirect_to pcg_settings_view_profile_path
     else
       redirect_to edit_pcg_home_path
     end
   end



  # TODO : future tasks - Next phase
  def index
    @care_giver = current_care_giver
    authorize @care_giver, :pcg_access?
    if current_care_giver
      @assigned_care_clients = current_care_giver.care_clients.list_care_clients(params[:search],sort_column,sort_direction,params[:page])
    end

  end

  def invite_family
    @care_giver_company = current_user.care_giver_company
    authorize @care_giver_company if @care_giver_company
  end

  def care_client_services
    @current_care_giver = current_care_giver
    @care_client = CareClient.find(params[:id])
    authorize @care_client
    if current_care_giver
      assigned_events = @current_care_giver.assigned_events.where('(assigned_events.status != ? or assigned_events.status is NULL)
                                                                     and care_client_id = ?', "submitted", params[:id])
    end
    # @assigned_events = assigned_events.search(params[:search]).page(params[:page]).per(10)
    @assigned_events = assigned_events.includes(:cc_event).list_care_clients(params[:search],sort_column_event,sort_direction,params[:page])
  end

  def view_my_services
    @assigned_event = AssignedEvent.find params[:id]
    authorize @assigned_event
    @event = @assigned_event.cc_event
    @care_client = CareClient.includes(:services => [:care_clients_services, :service_category]).find(@assigned_event.care_client_id)
    @services = @care_client.get_services(3)
    care_giver = current_user.care_giver
    @unchecked_assigned_event_id = ""
    @unchecked_assigned_event_id = care_giver.get_unchecked_assigned_event_id unless care_giver.checked_out_completely?
  end

  #Check-in process
  def edit_my_services
    @care_giver = current_care_giver
    @assigned_event = AssignedEvent.find params[:id]
    authorize @assigned_event 
    @assigned_event.update_attributes(checked_in_at: Time.now) unless @assigned_event.checked_in_at
    @care_client = CareClient.includes(:services => [:care_clients_services, :service_category]).find(@assigned_event.care_client_id)
    @services = @care_client.get_services(3)
    unless @assigned_event.status
      if @assigned_event.location_obtained?("checkin")
        check_in_distance = @assigned_event.get_distance([@assigned_event.latitude_checkin,@assigned_event.longitude_checkin],
        [@care_client.latitude,@care_client.longitude])
        DistanceAlertWorker.perform_async(@assigned_event.id,check_in_distance,"check_in") unless @assigned_event.status
      end
    end
    @assigned_event.set_status("checked_in") unless @assigned_event.status
  end

  #Save service status of a care giver
  def save_service_status
    @assigned_event = AssignedEvent.find(params[:id])
    if @assigned_event.set_status(params[:status])
      @assigned_event.service_record_json = params[:service_record_json]
      @assigned_event.distance_travelled = params[:distance].to_i
      @assigned_event.time_travelled = params[:time].to_f
      @assigned_event.signature = nil if params[:need_signature_deletion].to_s == "true"
      @assigned_event.save
       if params[:status] == "checked_out"
      if @assigned_event.location_obtained?("checkout")
        check_out_distance = @assigned_event.get_distance([@assigned_event.latitude_checkin,@assigned_event.longitude_checkin],
        [@assigned_event.latitude_checkout,@assigned_event.longitude_checkout])
        DistanceAlertWorker.perform_async(@assigned_event.id,check_out_distance,"check_out")
      end
    end
      flash[:notice] = "Successfully updated"
    else
      flash[:error]  = "Error in updation"
    end
    render nothing: true
  end

  #Save signature of a PCG
  def save_signature
    FileUtils::mkdir_p Rails.root.to_s + "/public/signatures" unless File.directory?(Rails.root.to_s + "/public/signatures")
    request_path =  request.fullpath[1..6] == "mobile" ? mobile_home_index_path : pcg_home_index_path
    if params[:output] != ""
      @assigned_event = AssignedEvent.find(params[:id])
      @assigned_event.update_attributes(signature: params[:output])
      instructions = JSON.load(params[:output]).map { |h| "line #{h['mx']},#{h['my']} #{h['lx']},#{h['ly']}" } * ' '
      system "convert -size 1000x300 xc:transparent -stroke blue -draw '#{instructions}' #{params[:id]}.png"

      FileUtils.mv(Rails.root.to_s+ "/#{params[:id]}.png", Rails.root.to_s + "/public/signatures")
      redirect_to request_path
    else
      redirect_to request_path
    end
  end

  #Save comment of a PCG
  def save_comment
    @assigned_event = AssignedEvent.find(params[:id])
    @comment = params[:comment].to_s
    @hidden_id =  params[:hidden_id].to_s
    record_status = @assigned_event.create_service_record(params[:service_record_json]) if @assigned_event.service_record_json.nil?
    unless @assigned_event.service_record_json.nil?
      tmp_json = @assigned_event.service_record_json
      params[:category]+params[:service]
      tmp_json[params[:category]][params[:service]]["msg"] = @comment
      @assigned_event.service_record_json = {}
      @assigned_event.save
      @assigned_event.service_record_json = tmp_json
      @assigned_event.save
    end
    test = @assigned_event.service_record_json
    @comment.gsub!("'","%%@%")  
    respond_to do |format|
      format.js
    end
  end

  #Submit PCG care services
  def submit_care_service
    request_path =  request.fullpath[1..6] == "mobile" ? mobile_home_index_path : pcg_home_index_path
    @assigned_event = AssignedEvent.find(params[:id])
    @assigned_event.set_status("submitted")
    redirect_to request_path and return
    flash[:notice] = "Care plan submitted Successfully!"
  end

  #View PCG Profile
  def settings_view_profile
    @care_giver_current = CareGiver.find(params[:id])
    authorize @care_giver_current
  end

  #Change PCG Password
  def settings_change_password
    @care_giver = CareGiver.find(params[:id])
    authorize @care_giver
  end

  #Update PCG Password
  def settings_update_password
    @care_giver = CareGiver.find(params[:id])
    if @care_giver.user.valid_password?(params[:current_password])
      @care_giver.update_attributes(pcg_params)
      if @care_giver.update_attributes(pcg_params)
        sign_in(@care_giver.user, :bypass => true)
        flash[:notice] = 'Password Changed Successfully!'
        redirect_to pcg_home_index_path
      else
        redirect_to pcg_settings_change_password_path(@care_giver.id)
        flash[:error] = "Error! Password not changed"
      end
    else
      redirect_to pcg_settings_change_password_path(@care_giver.id)
      flash[:notice] = "Current Password doesn't match!"
      flash[:error] = "Current Password doesn't match!"
    end
  end

	private

  #PCG Params
  def pcg_params
    params.require(:care_giver).permit(:first_name,:last_name,:address_1,:address_2,
      :country_id,:state_id,:city,:zip,:alternative_no,
      :mobile_no,:gender,:dob,:telephony_id,:highest_education,
      :school_year_graduated,:college_name,:year_graduated,
      :certificates,:training,:active_since,
      :emergency_first_name,:emergency_last_name,
      :emergency_phone_no1,:emergency_phone_no2,
      :emergency_notes,:care_giver_company_id,
      {:user_attributes => [:email, :id, :password, :password_confirmation]})
  end

  #Sort Columns
  def sort_column
    CareClient.column_names.include?(params[:sort]) ? params[:sort] : "status"
    #["first_name","last_name","service_time","status"].include?(params[:sort]) ? params[:sort] : "service_time"
  end

  def sort_column_event
    ["first_name","last_name","service_time","status"].include?(params[:sort]) ? params[:sort] : "service_time"
  end

  #Sort Directions
  def sort_direction
    %w[asc desc].include?(params[:direction]) ?  params[:direction] : "asc"
  end
end
