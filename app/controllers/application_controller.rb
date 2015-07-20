class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  include Pundit
  include ApplicationHelper

  before_filter :check_session, except: :get_company_session_url

  rescue_from Pundit::NotAuthorizedError, with: :permission_denied

  # Decides the page to load after sign in based on role.
  def after_sign_in_path_for(resource)
    session[:care_giver_company] = resource.care_giver_company.id if resource.care_giver_company
    if resource.has_role? :admin
      admin_home_index_path # <- Path you want to redirect the user to.
    elsif resource.has_role? :pcga
      pcga_home_index_path
    elsif resource.has_role? :pcg
      pcg_home_index_path
    elsif resource.has_role? :fcg
      fcg_home_index_path
    else
      web_root_path
    end
  end

  # Decides the page to load after sign out based on role.
  def after_sign_out_path_for(resource_or_scope)
    if current_user
      if current_user.has_role?(:pcg)
        if request.subdomain == "m"
          new_mobile_home_path
        else
          company_landing_path(current_custom_url)
        end
      else
        current_user.has_role?(:admin) ? web_root_path : company_landing_path(current_custom_url)
      end
    else
      web_root_path
    end
  end

  #To check session token
  def check_session
    if is_already_logged_in?
      login_url = session[:login_url]
      session[:login_url] = login_url
      @location = web_root_path
      if current_user
        if current_user.has_role?(:pcg)
          if request.subdomain == "m"
            @location = new_mobile_home_path
          else
            @location = company_landing_path(current_custom_url)
          end
        else
          @location = current_user.has_role?(:admin) ? web_root_path : company_landing_path(current_custom_url)
        end
      end
      reset_session
      session[:login_url] = login_url
      respond_to do |format|
        format.js { render :json => [], :status => :unauthorized }
        format.pdf { redirect_to @location }
        format.json { render :json => [], :status => :unauthorized }
        format.html { redirect_to @location }
      end
    end
  end

  def get_company_session_url
    render text: session[:login_url]
  end

  def is_already_logged_in?
    current_user && (session[:unique_session_id] != current_user.unique_session_id)
  end
  # Finds the current care giver company based on the user logged in.
  def current_care_giver_company
    @current_care_giver_company ||= CareGiverCompany.find(session[:care_giver_company])
  end

  #Find Current Care Giver
  def current_care_giver
    @current_care_giver ||= CareGiver.find(current_user.care_giver.id)
  end

  # Filtering privilages.
  def permission_denied
    if request.subdomain == "m"
      location = (request.referrer || mobile_home_index_path)
    else
      location = (request.referrer ||  after_sign_in_path_for(current_user))
    end
    redirect_to location, notice: "Unauthorized Access."
  end

  def get_state_list_pcga
    country = Country.find_by_name(params[:country])
    states = []
    states = country.states.order('name').collect{|d|[d.name,d.name]} if country
    @states = Hash[*states.flatten].to_json.html_safe
    @length = Hash[*states.flatten].length
    @type = params[:type]
    respond_to do |format|
      format.js { render "/shared/get_state_list_pcga.js.erb" }
    end
  end

  #Get States corresponding to each Country
  #POST /pcg/home/get_state_list
  def get_state_list
    country = Country.find_by_id(params[:country])
    if country
      states = State.where(country_id: country.id).order('name').collect{|d|[d.id,d.name]}
    else
      states = []
    end
    @states = Hash[*states.flatten].to_json.html_safe
    @length = Hash[*states.flatten].length
    @type = params[:type]
    respond_to do |format|
      format.js { render "/shared/get_state_list.js.erb" }
    end
  end

  def formatted_date(date, format = "%m-%d-%Y")
    Date.strptime(date,format)
  end

end
