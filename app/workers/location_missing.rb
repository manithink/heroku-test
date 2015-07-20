class LocationMissing

	include Sidekiq::Worker
	sidekiq_options :retry => false

	def perform(assigned_event_id,type)
		assigned_event = AssignedEvent.find assigned_event_id
		care_client = assigned_event.care_client
		care_giver = assigned_event.care_giver 
		admin_email = care_client.admin_email
		time = type == "checkin" ? assigned_event.checked_in_at : assigned_event.checked_out_at
		time = time.in_time_zone(care_client.time_zone)
		mode = type == "checkin" ? "checking in" : "checking out"
		content = "Location details of #{care_giver.fullname} was not obtained while #{mode} at #{time.strftime("%m/%d/%Y %H:%M:%S %p")} for #{care_client.fullname}'s sevices."
		AlertsMailer.location_missing(content,admin_email,care_giver.id).deliver! if care_giver.location_missing_alert_required?
	end

end