class Mobile::HomeController < ApplicationController
	helper_method :sort_column, :sort_direction
  
  before_filter :authenticate_user!, except: [:new, :login]
  
  layout 'application_mobile'

	#Mobile login page for pcg
  def new
  end

  #Login all pcg
  def login
  	@user = User.find_by_email params["user"]["email"]
  	if (@user && (@user.has_role? :pcg))
  		if @user.valid_password?(params["user"]["password"]) && @user.active_for_authentication?
  			sign_in(:user, @user)
        set_login_token
        @care_giver = @user.care_giver
				path = after_sign_in_path_for @user
				redirect_to mobile_home_index_path and return
			else
		 		redirect_to new_mobile_home_path, :alert => @user.get_login_validation_alert(params["user"]["password"])
			end
		else
			redirect_to new_mobile_home_path, :alert => "Email not found!"
		end
  end

  #Change PCG Password
  def settings_change_password
  	@care_giver = CareGiver.find(params[:id])
    authorize @care_giver, :pcg_access?
  end

  #Update PCG Password
  def settings_update_password
    @care_giver = CareGiver.find(params[:id])
    if @care_giver.user.valid_password?(params[:current_password])
      if @care_giver.update_attributes(pcg_params)
        sign_in(@care_giver.user, :bypass => true)
        flash[:notice] = 'Password Changed Successfully!'
        redirect_to mobile_settings_change_password_path(@care_giver.id)
      else
        flash[:notice] = "Password change error!"
        redirect_to mobile_settings_change_password_path(@care_giver.id)
      end
    else
      redirect_to mobile_settings_change_password_path(@care_giver.id)
      flash[:error] = "Current Password doesn't match!"
    end
  end

  #View/Edit Profile of PCG
  def settings_view_profile
    @care_giver = CareGiver.find(params[:id])
    authorize @care_giver, :pcg_access?
  end

  def mobile_signature
      # request_path =  request.fullpath[1..6] == "mobile" ? mobile_home_index_path : pcg_home_index_path
    if (params[:signature] != 'data:,')  
      @assigned_event = AssignedEvent.find(params[:id])
      @assigned_event.update_attributes(signature: params[:signature], service_record_json: params[:service_record_json])
      encoded_image = params[:signature].split(",")[1]
      decoded_image = Base64.decode64(encoded_image)
      File.open("public/signatures/#{params[:id]}.png", "wb") { |f| f.write(decoded_image) }
    end
   render partial: "shared/signature", locals: {assigned_event: @assigned_event}
  end

  #Update PCG Profile details
  def settings_update_profile
    @care_giver = CareGiver.find(params[:id])
    params[:care_giver][:dob] = formatted_date(params[:care_giver][:dob]) if params[:care_giver][:dob]
    if @care_giver.update_attributes(pcg_params)
      redirect_to mobile_settings_view_profile_path(@care_giver.id)
      flash[:notice] = "Changes Saved!"
    else
      redirect_to mobile_settings_view_profile_path(@care_giver.id)
      flash[:error] = "Error"
    end
  end

  def care_client_detail
    @care_giver = current_user.care_giver
    @care_client = CareClient.find(params[:id])
  end

  #Get States corresponding to each Country
  def get_state_list
    country = Country.find_by_id(params[:country])
    if country
      states = State.where(country_id: country.id).order('name').collect{|d|[d.id,d.name]}
    else
      flash[:error] = "Error"
      redirect_to mobile_settings_view_profile_path(@care_giver.id)
    end
  end

  #Index Page of PCG for responsive design
  def index
    @care_giver = current_care_giver
    @mr_or_name =  @care_giver.care_giver_company.is_private_record ? "medical_record_number": "first_name"
    if current_care_giver
      assigned_events = @care_giver.assigned_events.get_assigned_events(@care_giver)
    end
    @assigned_events = assigned_events.includes(:cc_event).mobile_list(sort_column,sort_direction)
  end

  def view_care_plan
    @assigned_event = AssignedEvent.find params[:id]
    authorize @assigned_event
    @event = @assigned_event.cc_event
    @care_client = CareClient.includes(:services => [:care_clients_services, :service_category]).find(@assigned_event.care_client_id)
    @services = @care_client.get_services(2)
    @care_giver = current_care_giver
    @unchecked_assigned_event_id = ""
    @unchecked_assigned_event_id = @care_giver.get_unchecked_assigned_event_id unless @care_giver.checked_out_completely?
  end

  def save_location
    @assigned_event = AssignedEvent.find(params[:id])
    if params[:status] == "checkin"
      @assigned_event.latitude_checkin,@assigned_event.longitude_checkin = params[:latitude],params[:longitude]
    elsif params[:status] == "checkout"
      @assigned_event.latitude_checkout,@assigned_event.longitude_checkout = params[:latitude],params[:longitude]
    end
    @assigned_event.save
    render nothing: true
  end

  #View Care Client services for PCG 
  def view_care_client_services
    @care_giver = current_care_giver
    @assigned_event = AssignedEvent.find params[:id]
    authorize @assigned_event
    @assigned_event.update_attributes(checked_in_at: Time.now) unless @assigned_event.checked_in_at
    @care_client = CareClient.includes(:services => [:care_clients_services, :service_category]).find(@assigned_event.care_client_id)
    @check_in_distance = @assigned_event.get_distance([@assigned_event.latitude_checkin,@assigned_event.longitude_checkin],
     [@care_client.latitude,@care_client.longitude])
    @check_out_distance = @assigned_event.get_distance([@assigned_event.latitude_checkin,@assigned_event.longitude_checkin],
     [@assigned_event.latitude_checkout,@assigned_event.longitude_checkout])
    @services = @care_client.get_services(2)
    unless @assigned_event.status
      if @assigned_event.location_obtained?("checkin")
        DistanceAlertWorker.perform_async(@assigned_event.id,@check_in_distance,"check_in") unless @assigned_event.status
      end
    end
    @assigned_event.set_status("checked_in") unless @assigned_event.status
  end

  private

  # White listing the sort_column attribute value.
  def sort_column
    ["first_name","last_name","service_time","status","medical_record_number"].include?(params[:sort]) ? params[:sort] : "service_time"
  end

  # White listing the sorting direction(sort_direction) attribute value.
  def sort_direction
    %w[asc desc].include?(params[:direction]) ?  params[:direction] : "asc"
  end
  
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

  def set_login_token
   token = Devise.friendly_token
   session[:unique_session_id] = token
   current_user.unique_session_id = token
   current_user.save(:validate => false)
   session[:login_url] = "/"
  end

end

