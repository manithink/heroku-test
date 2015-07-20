class ConfirmationsController < Devise::ConfirmationsController
  layout "device_pages"

  skip_before_filter :check_session

	def new
    super
  end

  def create
    super
  end

  # Redirects to "users/after_activation/:id/:set_password_token" 
  # after confirmation of a user by email.
  def show
    self.resource = resource_class.confirm_by_token(params[:confirmation_token])
    if resource.errors.empty?
      set_password_token = Devise.friendly_token.first(8)
      set_flash_message(:notice, :confirmed) if is_navigational_format?
      respond_with_navigational(resource){ redirect_to after_activation_path(resource, :set_password_token => set_password_token) }
    else
      respond_with_navigational(resource.errors, :status => :unprocessable_entity){ render :new }
    end
  end

end
