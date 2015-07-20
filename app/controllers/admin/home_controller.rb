class Admin::HomeController < ApplicationController
  helper_method :sort_column, :sort_direction
  before_filter :authenticate_user!

  # Show all care giver companies with search and sort.
  def index
    @care_giver_companies = CareGiverCompany.list_pcgc(sort_column,params[:search],params[:page],sort_direction)
    @care_companies = @care_giver_companies
  end

  # Show admin settings to generate dynamic content for landing page.
  def settings
    @image = Image.new
    @admin_data = AdminSetting.first
    @images = Image.where("id in(?)",@admin_data.image_ids).all
    authorize @admin_data
  end

  #save admin setting data in responds to an ajax request.

  def save_settings
    admin_setting = AdminSetting.first
    if admin_setting.update_admin_settings(params)
      render :json => { message: "Successfully saved"}
    else
      render :json => { message: "Data Not saved!!"}
    end
  end

  # Image uploading for landing page.
  def upload_settings_images
    @image = Image.new
    @image.image = params[:image][:image]
    if @image.save
      @admin_image = AdminSetting.first
      @admin_image.image_ids  += [@image.id]
      @admin_image.save
    end
    redirect_to admin_settings_path
  end

  # Delete admin imgaes.
  def delete_admin_images
    Image.find(params[:id]).destroy
    FileUtils.rm_rf(Rails.root.to_s + "/public/uploads/image/image/#{params[:id]}")
    @admin_image = AdminSetting.first
    @admin_image.image_ids -= [params[:id]]
    @admin_image.save
    redirect_to admin_settings_path
  end

  private

   # White listing image attributes.
  def image_params
    params.require(:image).permit(:image)
  end

  # Whitelisting admin setting attributes.
  def admin_setting_params
    params.require(:admin_setting).permit(:image_ids)
  end

  # Making default parameter for sorting as status. And also checks whether the sort
  # parameter is valid.
  def sort_column
    ["company_name","company_type","admin_first_name","phone","package_type","status", "company_type","active_care_clients", "active_care_givers"].include?(params[:sort]) ? params[:sort] : "status"
  end

  # no other parameter other than "asc" or "desc" is accepted.
  def sort_direction
    %w[asc desc].include?(params[:direction]) ?  params[:direction] : "asc"
  end
end
