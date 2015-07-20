class HomesController < ApplicationController

	layout 'landing_page'

  skip_before_filter :check_session

	# Landing page : "www.farcare.com"
  def index
  	@admin_data = AdminSetting.first
    @images = Image.where("id in(?)",@admin_data.image_ids).all
  end

  # Send mail to admin the mail id of the user.
  def get_more_info
  	GetMoreInfo.sent_info(params).deliver!
  	redirect_to web_root_path and return
  end
end
