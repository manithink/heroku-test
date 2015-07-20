class Pcga::HomeController < ApplicationController

  before_filter :authenticate_user!
  helper_method :sort_column, :sort_direction


  # Show all care givers and performs sort and search functionalities.
  def index
    if current_care_giver_company
      @care_givers = current_care_giver_company.care_givers.list_care_givers(params[:search],sort_column,sort_direction,params[:page])
    end
    # authorize @care_givers
  end

  # Changes status of care giver company.
	def change_status
		@status = params[:status]
		@company = CareGiverCompany.find(params[:id])
    authorize @company, :change_status?
    @company.status_change(params[:status])
		redirect_to admin_home_index_path(page: params[:page])
	end


  # Deletes care giver company.
	def delete_company
		@company = CareGiverCompany.find(params[:id])
    authorize @company, :delete_company?
		@company.destroy
	  redirect_to admin_home_index_path
	end

  # Data for creating a new care giver company.
  def new
    @care_giver_company = CareGiverCompany.new
    authorize @care_giver_company
    @care_giver_company.build_user
  end

  # creates a new user and saves in user and CareGiverCompany models
  # send mail to user for resetting password
  # POST /pcga/home
  def create
    password = Devise.friendly_token.first(8)
    params[:care_giver_company][:user_attributes][:password] =password rescue nil
    @care_giver_company = CareGiverCompany.new(pcga_params)
    authorize @care_giver_company
    if @care_giver_company.save
      user = @care_giver_company.user
      user.add_role :pcga
      # user.send_reset_password_instructions
      redirect_to admin_home_index_path
    else
      render 'new'
    end
  end

  # Edit and view PCGA details
  # GET /pcga/home/:id/edit
  def edit
    @care_giver_company = CareGiverCompany.find(params[:id])
    @pcga = CareGiverCompany.where('company_name != ?',"Farcare")
  end

  # Update PCGA details
  # PATCH /pcga/home/:id
  def update
    @care_giver_company = CareGiverCompany.find(params[:id])
    if @care_giver_company.update_attributes(pcga_params)
      if current_user.has_role? :admin
        redirect_to edit_pcga_home_path
      elsif current_user.has_role? :pcga
        redirect_to pcga_settings_view_profile_path(@care_giver_company.id)
      end
    else
      @error = true
      @pcga = CareGiverCompany.all
      render action: "edit"
    end
  end

  def invite_family
    @care_giver = current_user.care_giver
    authorize @care_giver if @care_giver
  end

  # Sent Invitation mails to Families
  # GET /pcga/invite_family
  # GET /pcg/invite_family
  def send_email_invite_family
    @emails = params[:emails]
    @content = params[:content]
    @url = current_custom_url
    if current_user.has_role? :pcga
      @user = current_care_giver_company.company_name
      @company_name = current_care_giver_company.company_name
    elsif current_user.has_role? :pcg
      @user = get_full_name(current_care_giver)
      @company_name = current_care_giver.care_giver_company.company_name
    end
    InviteFamilyMailer.invitation_email(@emails,@content,@url,@user,@company_name).deliver
    flash[:notice] = "Mail Sent Successfully"
    redirect_to pcga_invite_family_path
  end

  #List Services of a PCGA
  def list_services
    @category = ServiceCategory.new
    @categories = CareGiverCompany.includes(:service_categories => :services).find(current_care_giver_company)
  end

  #Save Category of PCGA
  def save_category
      @category = ServiceCategory.new(:name => params[:category][:name], :care_giver_company_id => current_user.care_giver_company.id)
      if @category.save
        flash[:notice] = "Category saved successfully!"
      else
        flash[:error] = "Category already exists!"
      end
    redirect_to pcga_list_services_path
  end

  #Save Services of PCGA
  def save_services
      @service = Service.new(:name => params[:name], :care_giver_company_id => current_care_giver_company.id,
                              :service_category_id => params[:category_id])
      if @service.save
        render :json => { success: "Service saved successfully" , category_id: @service.service_category_id, service_id: @service.id, name: @service.name }
      else
        render :json => { error: "Service already exist for this company" }
      end
  end

  #Delete Services of PCGA
  def delete_services
    @service = Service.find(params[:service_id])
    @service.delete
    render :json => {success: "Service has been deleted successfully"}
  end

  #Delete Category of PCGA
  def delete_category
    @category = ServiceCategory.find(params[:category_id])
    @category.destroy
    render :json => {success: "Category has been deleted successfully"}
  end


  #Genarate report of care_giver/ care_client using wicked-pdf.
  def report
    @zone = current_care_giver_company.get_time_zone
    @care_giver = current_user.care_giver
    authorize @care_giver if @care_giver
    if params[:role]
      @user_type = params[:role].titleize
      # @user_type = "Home Health Aide" if @user_type == "Care Giver"
      @other_user_type = @user_type.eql?("Care Client") ? "Care Giver" : "Care Client"
      @resource = params[:role].classify.constantize.find(params[:user_id])
      @start_date = formatted_date(params[:start_date])
      @end_date = formatted_date(params[:end_date])

      @assigned_events = @resource.assigned_events.where('date(created_at) between ? and ? and status in (?)', @start_date,@end_date, ["submitted"])
      @weeks = (@start_date.beginning_of_week .. @end_date.end_of_week).each_slice(7).to_a
      @service_record = {}

      @weeks.each_with_index do |week,index|
        @service_record[index] = {}
        week.each do |day|
          @service_record[index][day] = @assigned_events.select{|e| e.created_at.strftime("%x") == day.strftime("%x") }
        end
      end
    end
    respond_to do |format|
      format.html
      format.pdf do
        render :pdf                            => (@resource.fullname.to_s + "'s service report(#{@start_date} to #{@end_date})"),
               :disposition                    => 'attachment',                 # default 'inline'
               :show_as_html                   => false,      # allow debuging based on url param
               :orientation                    => 'portrait',
               :footer => { :center => '[page] of [topage]' }
      end
    end
  end

  # Get care giver or care client list in responds to ajax request.
  def get_users
    users = current_care_giver_company.care_clients.order('first_name').collect{|d|[d.id,d.fullname]} if params[:roles] == "care_client"
    users = current_care_giver_company.care_givers.order('first_name').collect{|d|[d.id,d.fullname]} if params[:roles] == "care_giver"
    users = [] unless users
    data = Hash[*users.flatten]
    @users = data.to_json.html_safe
    @length = data.length
    respond_to do |format|
      format.js
    end
  end

  # Settings page of pcga (fetching data).
  def settings
    @image = Image.new
    @care_giver_company = current_care_giver_company
    @admin_data = @care_giver_company.admin_setting
    @images = Image.where("id in(?)",@admin_data.image_ids).all
  end

  # Saves setting of pcga.
  def save_settings
    @care_giver_company = current_care_giver_company
    @admin_data = @care_giver_company.admin_setting
    @admin_data.update_attributes(admin_params)
    redirect_to pcga_settings_path
  end

  # Saving Logo image of a pcga.
  def upload_settings_images
    @image = Image.new
    @care_giver_company = current_care_giver_company
    @image.image = params[:image][:image]
    if @image.save
      @admin_image = @care_giver_company.admin_setting
      @admin_image.image_ids = [@image.id]
      @admin_image.save
    end
    redirect_to pcga_settings_path
  end

  # Deletes image associated with pcga.
  def delete_admin_images
    @image = Image.find(params[:id])
    FileUtils.rm_rf(Rails.root.to_s + "/public/uploads/image/image/#{@image.id}")
    @image.destroy
    redirect_to pcga_settings_path
  end

  #Yield assign care client page and preload with active care givers and care clients.
  def assign_care_clients_new
    @care_clients = current_care_giver_company.active_care_clients
    @care_givers =  current_care_giver_company.active_caregivers
  end

  # POST pcga/get_care_givers/:id
  # Get assign and unassigned Care Givers for a CC.
  def get_care_giver
    care_client = current_care_giver_company.care_clients.find(params[:id])
    care_givers = current_care_giver_company.care_givers
    assigned_care_givers = care_client.care_givers
    unassigned_care_givers = care_givers - assigned_care_givers
    @assigned_care_giver_ids = assigned_care_givers.map{|x| x.id}
    @unassigned_care_giver_ids = unassigned_care_givers.map{|x| x.id}

    respond_to do |format|
      format.js
    end
  end

  # POST pcga/assign_care_giver_to_careclient/:id/:care_client_id
  # Assign Care Giver to Care Client
  def assign_care_giver_to_careclient
    care_client = current_care_giver_company.care_clients.find(params[:care_client_id])
    care_giver = current_care_giver_company.care_givers.find(params[:id])
    unless care_client.care_givers.collect(&:id).include?(care_giver.id)
      care_client.care_givers << care_giver
    end
    render text: 'ok'
  end

  # POST pcga/unassign_care_giver_to_careclient/:id/:care_client_id
  # unassign Care Giver to Care Client
  def unassign_care_giver_to_careclient
    # render text: params
    care_client = current_care_giver_company.care_clients.find(params[:care_client_id])
    care_giver = current_care_giver_company.care_givers.find(params[:id])
    if care_client.care_givers.collect(&:id).include?(care_giver.id)
      care_client.care_givers.destroy care_giver
    end
    render text: 'ok'
  end

  # Data for view profile in settings page of pcga.
  def settings_view_profile
    @care_giver_company = CareGiverCompany.find(params[:id])
    @pcga = CareGiverCompany.all
    authorize @care_giver_company
  end

  # Data for password change under settings of pcga.
  def settings_change_password
    @care_giver_company = CareGiverCompany.find(params[:id])
    authorize @care_giver_company
  end

  # Updating password of pcga after changing password.
  def settings_update_password
    @care_giver_company = CareGiverCompany.find(params[:id])
    if @care_giver_company.user.valid_password?(params[:current_password])
      @care_giver_company.update_attributes(pcga_params)
      if @care_giver_company.update_attributes(pcga_params)
        sign_in(@care_giver_company.user, :bypass => true)
        flash[:notice] = 'Password Changed Successfully!'
        redirect_to pcga_home_index_path
      end
    else
      redirect_to pcga_settings_change_password_path(@care_giver_company.id)
      flash[:notice] = "Current Password doesn't match!"
      flash[:error] = "Current Password doesn't match!"
    end
  end

  # Data for care plan setting in settings page.
  def care_plan_setting
    @care_giver_company = CareGiverCompany.find(params[:id])
    authorize @care_giver_company
    @care_plan_setting = @care_giver_company.care_plan_setting
  end

  # Saving care plan setting of pcga.
  def update_care_plan_setting
    @care_plan_setting = CarePlanSetting.find(params[:id])
    if @care_plan_setting.update_attributes(care_plan_setting_params)
      flash[:notice] = "Settings Saved"
      redirect_to pcga_care_plan_setting_path(@care_plan_setting.care_giver_company.id)
    else
      flash[:notice] = "Settings Not Saved"
      redirect_to pcga_care_plan_setting_path(@care_plan_setting.care_giver_company.id)
    end

  end

  # Data for check in/out alerts in settings page.
  def settings_check_in_out_alerts
    @care_giver = CareGiver.find(params[:id]) rescue nil 
    if @care_giver
      authorize @care_giver
      @check_in_out_alerts = @care_giver.check_inout_alert
      @care_giver_company = @care_giver.care_giver_company
      @care_plan_setting = @care_giver_company.care_plan_setting
      @care_givers = @care_giver_company.care_givers.order('id ASC')
    else
      @care_giver_company = current_care_giver_company
    end
  end

  # Saving check in/out alerts of pcga.
  def update_check_in_out_alerts

    if params[:care_giver_ids]
      params[:care_giver_ids].each do |id|
        @care_giver = CareGiver.find id
        @check_in_out_alerts = @care_giver.check_inout_alert
        @check_in_out_alerts.update_attributes(check_in_out_alerts_params)
      end
      flash[:notice] = "Settings Saved"
      redirect_to pcga_settings_check_in_out_alerts_path(params[:care_giver_ids].first.to_i)
    else
      @check_in_out_alerts = CheckInoutAlert.find(params[:id])
      @care_giver = @check_in_out_alerts.care_giver
      flash[:alert] = "No Home Health Aide selected!!"
      redirect_to pcga_settings_check_in_out_alerts_path(@care_giver.id)
    end
    


    # @check_in_out_alerts = CheckInoutAlert.find(params[:id])
    # sdddsfdsf
    # @care_giver = @check_in_out_alerts.care_giver
    # if @check_in_out_alerts.update_attributes(check_in_out_alerts_params)
    #   flash[:notice] = "Settings Saved"
    #   redirect_to pcga_settings_check_in_out_alerts_path(@care_giver.id)
    # else
    #   flash[:notice] = "Settings Not Saved"
    #   redirect_to pcga_settings_check_in_out_alerts_path(@care_giver.id)
    # end
  end


  private

  #PCGA Params
  def pcga_params
    params.require(:care_giver_company).permit(:company_name, :address_1, :address_2, :city,
                                               :pcgc_state, :pcgc_country, :zip, :phone, :fax, :website,
                                               :year_founded, :organistaion_type_id,
                                               :admin_first_name, :admin_last_name, :admin_email,
                                               :admin_phone, :admin_time_zone, :alt_first_name,
                                               :alt_last_name, :alt_phone, :status,
                                               :subscription_state, :subscription_address_1,
                                               :subscription_address_2, :subscription_city ,
                                               :subscription_zip, :subscription_type_id,
                                               :package_type_id, :user_id, :subscription_country, :alt_email,
                                               :company_type_id, :checked,:is_private_record,
                                               {:user_attributes => [:email, :id, :password, :password_confirmation]})



  end

  def admin_params
    params.require(:admin_setting).permit(:about_us, :contact_us, :youtube_url, :image_ids, :custom_url)
  end


  def service_category_params
    params.require(:service_category).permit(:name, :care_giver_company_id)
  end

  def care_plan_setting_params
    params.require(:care_plan_setting).permit(:farcare_tracker_used,:end_of_week,:detect_late_checkout,:pcg_checkin_reminder_required, :pcg_checkin_reminder_time,
                                              :pcga_appointment_missed_alert_required, :pcga_appointment_missed_alert_time,
                                              :pcg_checkout_reminder_required, :pcg_checkout_reminder_time,
                                              :pcga_checkout_alert_required, :pcga_checkout_alert_time,
                                              :pcga_gps_mismatch_alert_required, :pcga_gps_mismatch_distance_min, :pcga_gps_mismatch_distance_max,:telephony_system_used, :call_in_no, :check_in_code, :check_out_code)
  end

    def check_in_out_alerts_params
    params.require(:check_inout_alert).permit(:confirmed_and_actual_notification,
                                              :confirmed_and_actual_warning,
                                              :confirmed_and_actual_alert,
                                              :checkin_and_checkout_notification,
                                              :checkin_and_checkout_warning,
                                              :checkin_and_checkout_alert,
                                              :send_email,
                                              :email,
                                              :send_sms,
                                              :sms)
  end


  def sort_column
    ["first_name","last_name","status","clients","package_type","status"].include?(params[:sort]) ? params[:sort] : "status"
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ?  params[:direction] : "asc"
  end

end
