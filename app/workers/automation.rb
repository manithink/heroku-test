class Automation

	include Sidekiq::Worker

	def perform(care_client_id)
		@care_client = CareClient.find(care_client_id)
		summary = @care_client.auto_assign
		admin_email = @care_client.admin_email
		AutoAssignSummaryMailer.send_summary(summary,admin_email).deliver!
	end

end