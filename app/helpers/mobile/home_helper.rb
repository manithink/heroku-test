module Mobile::HomeHelper

	def check_in_check_out_botton_mobile_path record
		edit_path = mobile_view_care_client_services_path(record.id)
		view_path =  mobile_view_care_plan_path(record.id)
		(record.status == "checked_in" || record.status == "checked_out" || record.status == "continue") ? edit_path : view_path
	end 
end
