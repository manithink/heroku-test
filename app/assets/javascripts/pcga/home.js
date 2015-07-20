$(document).ready(function() {
	$('#calendar_switch_care_client').change(function() {
		window.location.href = "/calendar/care_client/"+$(this).val() +"/index"
		// window.location = "http://stackoverflow.com/questions/21812532/jquery-redirect-to-another-page"
	})

	$('#calendar_switch_care_giver').change(function() {
		window.location.href = "/calendar/care_giver/"+$(this).val() +"/index"
		// window.location = "http://stackoverflow.com/questions/21812532/jquery-redirect-to-another-page"
	})
});