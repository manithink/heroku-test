class	DistanceAlertWorker
  include Sidekiq::Worker
  sidekiq_options :retry => false

  def perform(assigned_event_id,distance,activity)
  	assigned_event = AssignedEvent.find assigned_event_id
  	care_giver = assigned_event.care_giver
  	care_client = assigned_event.care_client
  	care_giver_company = care_giver.care_giver_company
  	@care_plan_setting = care_giver_company.care_plan_setting
  	check_in_out_setting = care_giver.check_inout_alert
  	phone = check_in_out_setting.send_sms ? check_in_out_setting.sms : care_giver_company.phone
  	email = check_in_out_setting.send_email ? check_in_out_setting.email : care_giver_company.user.email
  	variation_status = distance_variation_status(distance)
  	mode = activity == "check_in" ? "confirmed_and_actual" : "checkin_and_checkout"
  	mode_variable = (mode+"_"+variation_status).to_sym 
  	content = "GPS distance mismatch of #{distance} miles found for #{care_giver.fullname}'s #{activity.gsub("_"," ")} for #{care_client.fullname} "
  	send_message(email,phone,content,care_giver.id) if check_in_out_setting[mode_variable] 
  end

  def distance_variation_status(distance)
    distance_meter = (distance * 1609.34)
  	if (distance_meter < @care_plan_setting.pcga_gps_mismatch_distance_min.to_f &&
        distance_meter > 0)
  		status = "notification"
  	elsif (distance_meter > @care_plan_setting.pcga_gps_mismatch_distance_min.to_f &&
  					distance_meter < @care_plan_setting.pcga_gps_mismatch_distance_max.to_f)
  		status = "warning"
  	else
  		status = "alert"
  	end
  	status
  end

  def send_message(email,phone,content,care_giver_id)
    number_to_send_to = phone
    AlertsMailer.alert_email(email,content,care_giver_id).deliver

    twilio_client = Twilio::REST::Client.new TWILIO_SID, TWILIO_TOKEN

    twilio_client.account.sms.messages.create(
      :from => "+1#{TWILIO_PHONE}",
      :to => number_to_send_to,
      :body => content
    )
  end

end
