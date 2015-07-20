module Fcg::HomeHelper


	# For providing the class appropriate for each fcg based on status.
	def status_fcg (value, id,page)
		if (value == "Active")
			link_to "", fcg_change_status_path(id,"Active",page: page) , class: "status active"
		else
			link_to "", fcg_change_status_path(id,"Deactive",page: page) , class: "status"
		end	
	end

	def status_fcg_assigned (value)
		if (value == "Active")
			link_to "", "#" , class: "status active"
		else
			link_to "", "#" , class: "status"
		end	
	end

	#Home link for different users in breadcrum
	def home_breadcrumb
		if current_user.has_role? :pcga
		 link_to "Home",pcga_home_index_path 
		elsif current_user.has_role? :pcg
			link_to "Home",pcg_home_index_path 
		else
			link_to "Home", "#"
		end 
	end

	#Home link for different users in Care clients breadcrum
	def care_clients_breadcrumb
		if current_user.has_role? :pcga
		  link_to "Care Clients",fcg_view_care_clients_path, :class => "confirm"  
		elsif current_user.has_role? :pcg
			link_to "Care Clients",pcg_home_index_path
		else
			link_to "Care Clients", "#"
		end 
	end

	

end
