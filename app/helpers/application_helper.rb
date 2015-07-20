module ApplicationHelper


	# Adds sorting functionality to the coloumn titles.
	def sortable(column, title = nil)
    title ||= column.titleize
    css_class = (column == sort_column) ? "current #{sort_direction}" : nil
    direction = (column == sort_column && sort_direction == "asc") ? "desc" : "asc"
    link_to title, params.merge(:sort => column, :direction => direction, :page => nil), {:class => css_class}
  end

  # for sorting assigned events.
  def sortable_event(column, title = nil)
    title ||= column.titleize
    css_class = (column == sort_column_event) ? "current #{sort_direction}" : nil
    direction = (column == sort_column_event && sort_direction == "asc") ? "desc" : "asc"
    link_to title, params.merge(:sort => column, :direction => direction, :page => nil), {:class => css_class}
  end

  # Show flash messages.
  def get_flash_messages
		if flash.any?
			data = flash.collect do |key, msg|
				"<div class='farCare-#{key}'>#{msg}<a href='#' class='flash close'></a></div>"
			end
		return data.join.html_safe
		end
	end


	# Getting the time zone of the care giver company dynamically.
	def time_zone
		if current_user.has_role? :pcg
			time_zone = current_user.care_giver.care_giver_company.get_time_zone
		elsif current_user.has_role? :fcg
			time_zone = current_user.care_client.care_giver_company.get_time_zone
		elsif current_user.has_role? :pcga
			time_zone = current_user.care_giver_company.get_time_zone
		end
    time_zone
	end

	# Changing the name of care giver and care client
	def change_name(type)
		if type == "pcg"
			name = "HHA"
		elsif type == "Care Giver"
			name = "Home Health Aide"
		else
			type
		end
	end

	# Getting the custom url of a care giver company and its fcg and cc.
  def current_custom_url
    if current_user.has_role? :pcga
      return current_user.care_giver_company.admin_setting.custom_url
    elsif current_user.has_role? :pcg
      return current_user.care_giver.care_giver_company.admin_setting.custom_url
    elsif current_user.has_role? :fcg
      return current_user.care_client.care_giver_company.admin_setting.custom_url
    end
  end

  # Getting the logo image dynamically according to the care giver company
  # based on roles.
	def pcga_home_logo
		if current_user.has_role? :pcga
			@admin_setting = current_user.care_giver_company.admin_setting
		elsif current_user.has_role? :pcg
			@admin_setting = current_user.care_giver.care_giver_company.admin_setting
		elsif current_user.has_role? :fcg
			@admin_setting = current_user.care_client.care_giver_company.admin_setting
		end
		@logo = Image.where("id in(?)",@admin_setting.image_ids).last
		if @logo != nil
			return @logo.image rescue nil
		else
			return "landing-logo.png"
		end
	end

	# Finding the redirection path based on role after password updation.
	def password_reset_redirection_url(action)
		if action == "update_password"
			user = User.find(params[:id])
		elsif action == "forgot_password"
			user = User.find_by_email(params[:user][:email])
		end

		if user.has_role? :admin
			return new_user_session_path
		elsif user.has_role? :pcga
			return company_landing_path(user.care_giver_company.admin_setting.custom_url)
		elsif user.has_role? :pcg
			return company_landing_path(user.care_giver.care_giver_company.admin_setting.custom_url)
		elsif user.has_role? :fcg
			return company_landing_path(user.care_client.care_giver_company.admin_setting.custom_url)
		end
	end


	# For getting full name of pcga/pcg/fcg.
	def get_full_name resource
		resource.first_name.to_s + " " + resource.last_name.to_s
	end

	def get_full_name_pcga resource
		resource.admin_first_name.to_s + " " + resource.admin_last_name.to_s
	end

	def landing_page_url
	 "/#{current_user.roles.first.name}/home" if current_user
	end

	def pcg_bread_crumbs
		if current_user.has_role? :pcg
			"<li class='view'>  #{link_to 'PCG',pcga_home_index_path, :class => 'confirm'} </li>
		  <li class='edit'>#{ link_to 'PCG',pcga_home_index_path, :class => 'confirm', :id => 'pcg_edit_breadcrum_link'}</li>".html_safe
		elsif current_user.has_role? :admin
			"<li class='view'>  #{link_to 'Home',admin_home_index_path, :class => 'confirm'} </li>
		  <li class='edit'>#{ link_to 'Home',admin_home_index_path, :class => 'confirm', :id => 'pcg_edit_breadcrum_link'}</li>".html_safe
		elsif current_user.has_role? :pcga
			"<li class='view'>  #{link_to 'Home',pcga_home_index_path, :class => 'confirm'} </li>
		  <li class='edit'>#{ link_to 'Home',pcga_home_index_path, :class => 'confirm', :id => 'pcg_edit_breadcrum_link'}</li>".html_safe
		end
	end

	def company_time_zone
		admin_setting = AdminSetting.find_by_custom_url params[:screen_name]
		admin_setting.care_giver_company.get_time_zone if admin_setting && admin_setting.care_giver_company
	end
end
