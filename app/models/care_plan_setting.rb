class CarePlanSetting < ActiveRecord::Base
	store_accessor :alerts, :pcg_checkin_reminder_required, :pcg_checkin_reminder_time,
													:pcga_appointment_missed_alert_required, :pcga_appointment_missed_alert_time,
													:pcg_checkout_reminder_required, :pcg_checkout_reminder_time,
													:pcga_checkout_alert_required, :pcga_checkout_alert_time,
													:pcga_gps_mismatch_alert_required, :pcga_gps_mismatch_distance_min, :pcga_gps_mismatch_distance_max



	store_accessor :telephony, :telephony_system_used, :call_in_no, :check_in_code, :check_out_code

	validates :end_of_week, :presence => true
	belongs_to :care_giver_company

	after_update :update_reminderalert_job

	def update_reminderalert_job
	  zone = care_giver_company.get_time_zone
		if alerts_was
			options = {change_pcg_checkin_reminder_time: alerts["pcg_checkin_reminder_time"] != alerts_was["pcg_checkin_reminder_time"],
								change_pcga_appointment_missed_alert_time: alerts["pcga_appointment_missed_alert_time"] != alerts_was["pcga_appointment_missed_alert_time"],
							 	change_pcg_checkout_reminder_time: alerts["pcg_checkout_reminder_time"] != alerts_was["pcg_checkout_reminder_time"],
							 	change_pcga_checkout_alert_time: alerts["pcga_checkout_alert_time"] != alerts_was["pcga_checkout_alert_time"]
								}
			UpdateAlertreminderWorker.perform_async(care_giver_company.id, options)
		end
	end
end
