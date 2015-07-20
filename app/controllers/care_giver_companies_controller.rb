class CareGiverCompaniesController < ApplicationController
	layout 'company_landing_page'
	
	skip_before_filter :check_session

	# Landing page of PCGC company
	def new
		@admin_setting = AdminSetting.find_by_custom_url params[:screen_name]
		@care_giver_company = @admin_setting.care_giver_company if @admin_setting
		redirect_to web_root_path and return unless @admin_setting  and @care_giver_company
		@care_client = CareClient.new
		@care_client.build_user
		@logo = Image.where("id in(?)",@admin_setting.image_ids).last
	end

	#Login all users under a company
	def login
		@care_giver_company = CareGiverCompany.find(params[:id])
		@user = User.find_by_email params["user"]["email"]
		location = @care_giver_company.admin_setting ? "/#{@care_giver_company.admin_setting.custom_url}" : '/'
		if (@care_giver_company && @user) && @care_giver_company.include_user?(@user)
			if @user.valid_password?(params["user"]["password"]) && @user.active_for_authentication?
				sign_in(:user, @user)
				set_login_token
				path = after_sign_in_path_for @user
				redirect_to path and return
			else
				alert = @user.get_login_validation_alert(params["user"]["password"])
				redirect_to location, :alert => alert
			end
		else
			redirect_to location, :alert => "You are not authorized to login!"
		end
	end

  #create a new care client under company
	def create
		password = Devise.friendly_token.first(8)
    params[:care_client][:user_attributes][:password] = password rescue nil
    params[:care_client][:dob] = formatted_date(params[:care_client][:dob]) if params[:care_client][:dob]
		@care_client = CareClient.new(fcg_params)
		if @care_client.register(params, params[:id], false)
			redirect_to company_landing_path(@care_client.care_giver_company.admin_setting.custom_url), notice: "Successfully Registered"
		else
			render action: :new
		end
	end

	private

	#FCG Params
	def fcg_params
    params.require(:care_client).permit(:first_name,
    																		:last_name,
    																		:dob,
    																		:telephone,
    																		:mobile_no,
    																		:time_zone,
    																		:account_type,
																				:last_name,
																				{
																					:user_attributes => [:email, :password]
																				})
  end

  def set_login_token
   token = Devise.friendly_token
   session[:unique_session_id] = token
   current_user.unique_session_id = token
   session[:login_url] = company_landing_path(current_custom_url)
   current_user.save(:validate => false)
 end

end
