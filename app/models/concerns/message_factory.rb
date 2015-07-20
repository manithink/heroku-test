class MessageFactory
	REMINDER_CHECK_IN = "Hi %{care_giver_name}, you have a appointment for %{care_client_name} at %{starttime}."
	REMINDER_CHECK_OUT = "Hi %{care_giver_name}, you have not checked out of an appointment for %{care_client_name} at %{endtime}."
	ALERT_CHECK_IN = "Hi %{company_admin_name}, %{care_giver_name} has not checked in for a appointment for %{care_client_name} at %{starttime}.Please take necessary action."
	ALERT_CHECK_OUT = "Hi %{company_admin_name}, %{care_giver_name} has not checked out of an appointment for  %{care_client_name} at %{endtime} Please take necessary action."
	def self.get_message(mode, type, options)
		mode_type = "#{mode}_#{type}".upcase
		Kernel.const_get("MessageFactory::#{mode_type}") % options
	end

end

