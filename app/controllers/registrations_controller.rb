class RegistrationsController < Devise::RegistrationsController
	
	def edit
		@user = User.find_by_confirmation_token(params[:confirmation_token])
	end

  def update
  	u = User.find_by_email params[:user][:email]
  	u.update_attributes(password: params[:user][:password]) if params[:user][:password] == params[:user][:password_confirmation]
  	# render text: params and return
  end
end