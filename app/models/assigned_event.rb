class AssignedEvent < ActiveRecord::Base
  belongs_to :care_client
  belongs_to :care_giver
  belongs_to :cc_event, :class_name => 'Event', :foreign_key => :cc_event_id
  belongs_to :pcg_event, :class_name => 'Event', :foreign_key => :pcg_event_id

  validates_presence_of :cc_event_id, :message => "Care Client Event is not associated"
  validates_presence_of :pcg_event_id, :message => "HHA Event is not associated"
  validates_presence_of :care_client_id, :message => "Care Client is not associated"
  validates_presence_of :care_giver_id, :message => "Care Giver is not associated"

  validates :cc_event_id, uniqueness: { scope: :pcg_event_id, message: "Should linked to Once" }

  before_destroy :change_event_status, :remove_worker_from_queue, :merge_pcg_events

  after_create :create_alert_reminder_worker


  def self.search(search)
    if search
      joins(:care_client).where('LOWER(name) LIKE ?', "%#{search.downcase}%")
    else
      joins(:care_client)
    end
  end

  def create_alert_reminder_worker
    job_ids = {}
    time_zone = pcg_event.item.get_time_zone
    care_giver_company = pcg_event.care_giver_company
    starttime = current_time(pcg_event.starttime, time_zone)
    endtime = current_time(pcg_event.endtime, time_zone)
    job_ids["alert_check_in"] = AlertsReminders.perform_at((starttime + care_giver_company.check_in_alert_time),pcg_event.id, "check_in", "alert", ["closed"] ) #if care_giver_company.alert_check_in_required?
    job_ids["reminder_check_in"] = AlertsReminders.perform_at((starttime - care_giver_company.check_in_reminder_time),pcg_event.id, "check_in","reminder", ["closed"]) #if care_giver_company.reminder_check_in_required?
    job_ids["alert_check_out"] = AlertsReminders.perform_at((endtime + care_giver_company.check_out_alert_time),pcg_event.id, "check_out","alert", ["checked_in", "continue"]) #if care_giver_company.alert_check_out_required?
    job_ids["reminder_check_out"] = AlertsReminders.perform_at((endtime + care_giver_company.check_out_reminder_time),pcg_event.id, "check_out","reminder", ["checked_in", "continue"]) #if care_giver_company.reminder_check_out_required?
    self.alertreminderjob_ids = job_ids
    self.save(validate: false)
  end

  # Sorting, searching, listing process of assigned events of a care giver.
  def self.list_care_clients(search,sort_column,sort_direction,page)
    unless sort_column == "service_time"
      search(search).order(sort_column + ' ' + sort_direction).page(page).per(10)
    else
      joins(:cc_event).order("starttime"+ ' ' + sort_direction).search(search).page(page).per(10)
    end
  end

  def self.get_assigned_events(care_giver)
    date = DateTime.now.convert_to(care_giver.time_zone).beginning_of_day - 1.day
    joins(:cc_event).where('(assigned_events.status != ? or assigned_events.status is NULL) AND starttime >= ?', "submitted", date)
  end

  # Sorting process of events in responsive design
  def self.mobile_list(sort_column,sort_direction)
    if sort_column == "service_time"
      order("starttime"+ ' ' + sort_direction)
    else
      joins(:care_client).order(sort_column + ' ' + sort_direction)
    end
  end

  def set_status(current_status = nil)
    valid_statuses = %w(checked_in continue checked_out submitted)
    if current_status
      valid_status = valid_statuses.include?(current_status) ? current_status : nil
      if valid_status
        self.status = valid_status
        care_client_event = self.cc_event
        care_client_event.update_status(valid_status)
        care_giver_event = self.pcg_event
        care_giver_event.update_status(valid_status)
        self.checked_out_at = Time.now if valid_status == "checked_out"
        self.save
      end
    end
  end

  def report_date type
    if type == "checked_in"
      checked_in_at.strftime("%m/%d/%Y")
    else
      checked_out_at.strftime("%m/%d/%Y")
    end
  end

  def report_time type, zone
    if type == "checked_in"
      checked_in_at.in_time_zone(zone).strftime("%H:%M%P")
    else
      checked_out_at.in_time_zone(zone).strftime("%H:%M%P")
    end
  end

  def get_distance(location1, location2)
    result = Geocoder::Calculations.distance_between(location1, location2).round(6)
    result.nan? ? 0 : result
  end

  def create_service_record params
    self.service_record_json = params
    self.save
  end

  def location_obtained? type
    latitude = "latitude_"+type
    longitude = "longitude_"+type
    if (self.send(latitude) == nil && self.send(longitude) == nil)
      LocationMissing.perform_async(self.id,type)
      false
    else
      true
    end
  end

  # private

  def change_event_status
    if pcg_event
      pcg_event.status = "available"
      pcg_event.save(validate: false)
    end
    if cc_event
      cc_event.status = "available"
      cc_event.save(validate: false)
    end
  end

  def remove_worker_from_queue
    alertreminderjob_ids.values.each do |alertreminderjob_id|
      Sidekiq::Status.unschedule alertreminderjob_id
    end
  end

  def merge_pcg_events
    if pcg_event
      events = pcg_event.get_consecutive_splitup_events
      pcg_event.starttime = events[0].starttime unless events[0].nil?
      pcg_event.endtime = events[1].endtime unless events[1].nil?
      events[0].destroy unless events[0].nil?
      events[1].destroy unless events[1].nil?
      pcg_event.save(validate: false)
    end
  end

  def current_time(datetime, zone)
  	diff = (datetime.in_time_zone(zone).utc_offset.to_f/3600)
  	datetime = datetime - diff.hours
  end

  def parse_for_compare(a)
    DateTime.parse("#{a.hour}:#{a.min}:#{a.sec}, #{a.day}-#{a.month}-#{a.year}")
  end
end
