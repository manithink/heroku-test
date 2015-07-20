module Admin::HomeHelper

	# For providing the class appropriate for each company based on status.
	def status (value, id,page)
		if (value == "Active")
			link_to "", pcga_change_status_path(id,"Active",page: page) , class: "status active"
		else
			link_to "", pcga_change_status_path(id,"Deactive",page: page) , class: "status"
		end	
	end
end
