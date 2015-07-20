class UpdateAlertreminderWorker
  include Sidekiq::Worker

  def perform(company_id, options)
    company = CareGiverCompany.find(company_id)
    zone = company.get_time_zone
    assigned_events = AssignedEvent.joins(:pcg_event).where('events.starttime >= ?', DateTimeCompare.current_date_time(zone))
    assigned_events.each do |assigned_event|
      job_ids = assigned_event.alertreminderjob_ids
      pcg_event= assigned_event.pcg_event
      starttime = assigned_event.current_time(pcg_event.starttime, zone)
      endtime = assigned_event.current_time(pcg_event.endtime, zone)


      if(options["change_admin_time_zone"])
        p "Time Zone Changed to #{zone} - #{company.company_name}"
        job_ids.values.each do |alertreminderjob_id|
          Sidekiq::Status.unschedule alertreminderjob_id
        end
        job_ids["alert_check_in"] = AlertsReminders.perform_at((starttime + company.check_in_alert_time), pcg_event.id, "check_in", "alert", ["closed"])
        job_ids["reminder_check_in"] = AlertsReminders.perform_at((starttime - company.check_in_reminder_time), pcg_event.id, "check_in","reminder", ["closed"])
        job_ids["alert_check_out"] = AlertsReminders.perform_at((endtime + company.check_out_alert_time), pcg_event.id, "check_out","alert", ["checked_in", "continue"])
        job_ids["reminder_check_out"] = AlertsReminders.perform_at((endtime + company.check_out_reminder_time), pcg_event.id, "check_out","reminder", ["checked_in", "continue"])
        p job_ids
      end

      if(options["change_pcg_checkin_reminder_time"])
        p "Performing CheckIN Reminder"
        key = "reminder_check_in"
        old_job_id = job_ids[key]
        Sidekiq::Status.cancel  old_job_id
        time = -company.check_in_reminder_time
        time = (starttime + time)
        job_ids[key] = AlertsReminders.perform_at(time, pcg_event.id, "check_in","reminder", ["closed"])
      end

      if(options["change_pcga_appointment_missed_alert_time"])
        p "Performing CheckIN Alert"
        key = "alert_check_in"
        old_job_id = job_ids[key]
        Sidekiq::Status.cancel  old_job_id
        time = company.check_in_alert_time
        time = (starttime + time)
        job_ids[key] = AlertsReminders.perform_at(time, pcg_event.id, "check_in","alert", ["closed"])
      end

      if(options["change_pcg_checkout_reminder_time"])
        p "Performing CheckOut Reminder"
        key = "reminder_check_out"
        old_job_id = job_ids[key]
        Sidekiq::Status.cancel  old_job_id
        time = company.check_out_reminder_time
        time = endtime + time
        job_ids[key] = AlertsReminders.perform_at(time, pcg_event.id, "check_out","reminder", ["checked_in", "continue"])
      end

      if(options["change_pcga_checkout_alert_time"])
        p "Performing CheckOut Alert"
        key = "alert_check_out"
        old_job_id = job_ids[key]
        Sidekiq::Status.cancel  old_job_id
        time = company.check_out_alert_time
        time = endtime + time
        job_ids[key] = AlertsReminders.perform_at(time, pcg_event.id, "check_out","alert", ["checked_in", "continue"])
      end
      assigned_event = AssignedEvent.find(assigned_event)
      assigned_event.alertreminderjob_ids = job_ids
      assigned_event.save(validate: false)
    end
  end
end
