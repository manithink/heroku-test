class HomeController < Devise::SessionsController

  skip_before_filter :check_session

  def new
    super
  end

  def create
    @user = User.find_by_email(params[:user][:email])
    if @user and @user.has_role? :admin and @user.valid_password?(params["user"]["password"]) and @user.active_for_authentication?
      sign_in(:user, @user)
      set_login_token
      path = after_sign_in_path_for @user
      redirect_to path and return
    else
      redirect_to new_user_session_path, :alert => "Username or Password incorrect"
    end
  end

  def destroy
    login_url = session[:login_url]
    reset_session
    session[:login_url] = login_url
    redirect_to login_url
  end

  private

  def set_login_token
    token = Devise.friendly_token
    session[:unique_session_id] = token
    current_user.unique_session_id = token
    session[:login_url] = "/users/sign_in"
    current_user.save(:validate => false)
  end
end
