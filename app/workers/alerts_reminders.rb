class AlertsReminders

  include Sidekiq::Worker
  sidekiq_options :retry => false

  def perform(event_id, type, mode, statuses)
    event = Event.find event_id
    care_giver = event.item
    care_client = event.pcg_assigned_event.care_client
    care_giver_company = event.care_giver_company
    required_string = "#{mode}_#{type}_required?"

    if mode == "reminder"
      email = event.care_giver_mail
      phone = event.care_giver_phone
    else
      email = event.care_company_mail
      phone = event.care_giver_company.phone
    end

    options = { care_giver_name: care_giver.fullname,
                care_client_name: care_client.fullname,
                company_admin_name: event.care_giver_company.admin_fullname,
                starttime: event.starttime.strftime("%m/%d/%Y %H:%M:%S %p"),
                endtime: event.endtime.strftime("%m/%d/%Y %H:%M:%S %p")}

    content = MessageFactory.get_message(mode, type, options)
    send_message(email,phone,content,care_giver.id) if (statuses.include?(event.status) && care_giver_company.send(required_string))

=begin
    send_message(email,phone,content) if (event.status == "checked_in" || event.status == "continue")

    ["closed"]
    ["checked_in", "continue"]


    if type == "check_in"
      if mode == "reminder"
        content = "Hi #{}, you have a appointment for #{care_client.fullname}"+
          " at #{event.starttime.strftime("%d/%m/%Y %H:%M:%S %p")}."
      else
        content = "Hi #{event.care_giver_company.admin_fullname}, #{care_giver.fullname} "+
          "has not checked in for a appointment for #{care_client.fullname} "+
          "at #{event.starttime.strftime("%d/%m/%Y %H:%M:%S %p")}.Please take necessary action."
      end
      send_message(email,phone,content) if event.status == "closed"

    elsif type == "check_out"
      if mode == "reminder"
        content = "Hi #{care_giver.fullname}, you have not checked out of an appointment for #{care_client.fullname} "+
          " at #{event.endtime.strftime("%d/%m/%Y %H:%M:%S %p")}."
      else
        content = "Hi #{event.care_giver_company.admin_fullname}, #{care_giver.fullname} has not checked out "+
          " of an appointment for #{care_client.fullname} at #{event.endtime.strftime("%d/%m/%Y %H:%M:%S %p")}. "+
          "Please take necessary action."
      end
      send_message(email,phone,content) if (event.status == "checked_in" || event.status == "continue")
    end
=end
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
