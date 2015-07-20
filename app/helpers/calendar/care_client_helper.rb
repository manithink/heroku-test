module Calendar::CareClientHelper

	def alert_pcg_availablity care_givers
		'<div class="calender-alert">HHAs are not available!!</div><br>'.html_safe if care_givers.empty?
	end
end
