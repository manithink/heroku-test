class UsersController < ApplicationController
  def new
  @user = User.new
end
 def test
  @text = "Welcome"
end

def create
  @user = User.new(user_params)
  if @user.save
    redirect_to log_in_path, :notice => "Signed up Sucessfully, Now login to Ur Account!"
  else
    render "new"
  end
end

private
  	def user_params
    	params.require(:user).permit(:email, :password, :password_confirmation)
  	end
end
