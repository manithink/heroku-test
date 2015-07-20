class PasswordsController < Devise::PasswordsController

	layout "device_pages"
  
  #Path after sending Reset Password Instruction
  def after_sending_reset_password_instructions_path_for(resource_name)  	
    password_reset_redirection_url("forgot_password")
  end
  
  #After Activation of User Account
  def after_activation	
	  	@resource = User.find(params[:id])
	    @resource.reset_password_token   = params[:set_password_token]
	    @resource.reset_password_sent_at = Time.now.utc
      @resource.save(validate: false)
      render layout: "device_pages" 	
  end

  #Set Password Token
  def set_password 
    @user = User.find(params[:id])
    @token = params[:set_password_token]
  end

  #Update User Password
  def update_password
    @user = User.find(params[:id])
    if @user.reset_password_token == params[:set_password_token]
      if @user.update_attributes(user_params)
        @user.reset_password_token   = nil
        @user.save(validate: false)
        redirect_to password_reset_redirection_url("update_password")
      else
        flash[:errors] = "Password not set , Retry"
        redirect_to set_password_path(@user,:set_password_token => params[:set_password_token])
      end
    else
      flash[:errors] = "Token Invalid"
      redirect_to set_password_path(@user,:set_password_token => params[:set_password_token])    
    end
  end

  private

  #User Params
  def user_params
    params.require(:user).permit(:password,:password_confirmation)
  end
  
end
	