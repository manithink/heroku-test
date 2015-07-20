module Pcga::HomeHelper
	
	# for providing the class appropriate for each company based on status.
	def status_pcg (value, id,page)
		if (value == "Active")
			link_to "", pcg_change_status_path(id,"Active",page: page) , class: "status active"
		else
			link_to "", pcg_change_status_path(id,"Deactive",page: page) , class: "status"
		end
	end


	# setting default value for gps mismatch distance minimum.
	def min_distance(care_plan_setting)
		if care_plan_setting.pcga_gps_mismatch_distance_min
			care_plan_setting.pcga_gps_mismatch_distance_min
		else
			return "122"
		end
	end

	# setting default value for gps mismatch distance maximum.
	def max_distance(care_plan_setting)
		if care_plan_setting.pcga_gps_mismatch_distance_max
			care_plan_setting.pcga_gps_mismatch_distance_max
		else
			return "301"
		end
	end

	#Select box content added
	def  mult_select_box(pcg)
		"<option value = #{pcg.id}> #{pcg.fullname} </option>".html_safe
  end

  def time_format(seconds)
  	hours = (seconds / 3600).to_i
  	minutes = ((seconds % 3600) /  60).to_i
  	return "#{hours} : #{minutes}"
  end

end
