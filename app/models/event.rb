class Event < ActiveRecord::Base

  attr_accessor :period, :frequency, :commit_button, :upto

  # validates :title, :description, :presence => true
  validate :validate_timings, :only_one_event_for_pcg, :checking_vacation
  validate :not_update_closed_event, on: :update


  belongs_to :event_series
  belongs_to :item, polymorphic: true

  has_one :cc_assigned_event, :class_name => 'AssignedEvent', :foreign_key => :cc_event_id, :dependent => :destroy
  has_one :pcg_assigned_event, :class_name => 'AssignedEvent', :foreign_key => :pcg_event_id , :dependent => :destroy

  has_one :pcg_event, :class_name => 'Event', through: :cc_assigned_event
  has_one :cc_event, :class_name => 'Event', through: :pcg_assigned_event

  before_destroy :destroy_assigned_event

  before_save :change_starttime_endtime_for_allday


  REPEATS = {
    :no_repeat => "Does not repeat",
    :days      => "Daily",
    :weeks     => "Weekly",
    :months    => "Monthly",
    :years     => "Yearly"
  }

  DUP_REPEATS = ['no_repeat', 'day', 'week', 'month', 'year']

  PROCESSED_STATUS = [ "checked_in", "checked_out", "continue", "submitted"]
  UNPROCESSED_STATUS = ["available", "closed"]

  def self.get_events_with_start_and_end_date(start_time, end_time)
    start_time = (Time.at(start_time.to_i) - 1.days).to_formatted_s(:db)
    end_time = (Time.at(end_time.to_i) + 1.days).to_formatted_s(:db)
    where('starttime  >= :start_time and endtime <= :end_time', start_time: start_time, end_time: end_time)
  end

  def self.get_only_future_events(start_time, end_time, zone)
    current_time = DateTimeCompare.current_date_time(zone)
    start_time = (Time.at(start_time.to_i) - 1.days).to_formatted_s(:db)
    end_time = (Time.at(end_time.to_i) + 1.days).to_formatted_s(:db)
    data_lists = where('starttime  >= :start_time and endtime <= :end_time and status = :stats', start_time: start_time, end_time: end_time, stats: "available")
    data_lists.where('endtime >= :end_time', end_time: current_time)
  end

  def self.get_appointments_with_start_and_end_date(start_time, end_time)
    start_time = (Time.at(start_time.to_i) - 1.days).to_formatted_s(:db)
    end_time = (Time.at(end_time.to_i) + 1.days).to_formatted_s(:db)
    data_lists = where('starttime  >= :start_time and endtime <= :end_time', start_time: start_time, end_time: end_time)
    data_lists.where(status: ["closed","checked_in", "checked_out", "continue", "submitted"])
  end

  def self.get_event_json(event_lists)
    events = []
    event_lists.each do |event|
      events << { id: event.id,
                  title: event.get_title_for_event_json,
                  description: event.description || '',
                  start: event.starttime.iso8601,
                  end: event.endtime.iso8601,
                  allDay: event.all_day,
                  color: event.color,
                  textColor: 'black',
                  is_edit: event.is_edit,
                  recurring: (event.event_series_id) ? true : false,
                  recurring_period: event.event_series.nil? ? '' : event.event_series.frequency_text,
                  status: event.status,
                  cc_assigned_event: event.cc_assigned_event.nil? ? '' :  event.cc_assigned_event.id,
                  pcg_assigned_event: event.pcg_assigned_event ? event.pcg_assigned_event.id : '',
                  assigned_path_name: event.assigned_path_name,
                  item_type_status: event.item_type_status
                  }
    end
    events
  end

  def get_title_for_event_json
    return title if status == "available"
    appointment_title = ""
    case item_type
    when "CareGiver"
      appointment_title = pcg_assigned_event.care_client ? "Appointment with #{pcg_assigned_event.care_client.fullname}" : title
    when "CareClient"
      appointment_title = cc_assigned_event.care_giver ? "Appointment with #{cc_assigned_event.care_giver.fullname}" : title
    end
    appointment_title
  end

  def change_starttime_endtime_for_allday
    if self.all_day
      self.starttime = self.starttime.beginning_of_day
      self.endtime = self.endtime.end_of_day
    end
  end

  def not_update_closed_event
    case status_was
    when "checked_in", "checked_out", "continue", "submitted"
      errors[:base] << "Not able to Update, this Event already moved to checked In/Cheked Out Process"
    when "closed"
      if starttime.to_s(:db) <= DateTime.now.to_s(:db)
        errors[:base] << "Not able to Update, this event is past!!"
      elsif (starttime_was != starttime) || (endtime_was != endtime) ||  (all_day_was !=  all_day)
        errors[:base] << "Not able to update Start time and End time since its scheduled event!!"
      end
    end
  end

  def is_range_of_connected_event?
    connected_event = item_type == "CareGiver" ? cc_event : pcg_event
    (connected_event.starttime..connected_event.endtime).cover?(starttime) && (connected_event.starttime..connected_event.endtime).cover?(endtime)
  end

  def validate_timings
    zone = get_zone
    # current_date_time = parse_for_compare(DateTime.now.convert_to(zone))
    if (starttime.nil? or endtime.nil?)
      errors[:base] << "Invalid Date !"
    elsif (starttime >= endtime) and !all_day
      errors[:base] << "Start Time must be less than End Time"
    elsif (starttime.strftime("%Y:%m:%d") != endtime.strftime("%Y:%m:%d"))
      errors[:base] << "Start date and End date should be same"
      # elsif (parse_for_compare(starttime) < current_date_time or parse_for_compare(endtime) <  current_date_time)
    elsif DateTimeCompare.is_past?(starttime, zone) or DateTimeCompare.is_past?(starttime, zone)
      errors[:base] << "Not allow to create past events"
    end
  end

  def get_zone
    class_type = Object.const_get(item_type.classify)
    class_type.find(item_id).get_time_zone
  end

  def checking_vacation
    if item_type == 'CareGiver'
      care_giver = CareGiver.find item_id
      start_week = starttime.beginning_of_week(start_day = :sunday) - 1.week
      end_week = endtime.end_of_week(start_day = :sunday) + 1.week
      vacation_lists = care_giver.vacation_managements.where('startdate  >= :start_time and enddate <= :end_time', start_time: start_week, end_time: end_week).where( status: ["accepted"])
      endtime = all_day ?  self.endtime.end_of_day : self.endtime
      vacation_lists.each do |vacation_list|
        if (vacation_list.startdate..vacation_list.enddate).cover?(starttime+1.minutes) || (vacation_list.startdate..vacation_list.enddate).cover?(endtime - 1.minutes) || (starttime..endtime).cover?(vacation_list.startdate + 1.minutes) || (starttime..endtime).cover?(vacation_list.enddate - 1.minutes)
          errors[:base] << "PCG is on vacation at this time slot!!"
          return
        end
      end
    end
  end

  def only_one_event_for_pcg
    if item_type == 'CareGiver'
      care_giver = CareGiver.find item_id
      start_day = starttime.beginning_of_day
      end_day = endtime.end_of_day
      event_lists = care_giver.events.where('starttime  >= :start_time and endtime <= :end_time', start_time: start_day, end_time: end_day)
      event_lists = event_lists.delete_if{|event| event.id == id }
      endtime = all_day ? end_day : self.endtime
      event_lists.each do |event|
        if (event.starttime..event.endtime).cover?(starttime+1.minutes) || (event.starttime..event.endtime).cover?(endtime - 1.minutes) || (starttime..endtime).cover?(event.starttime + 1.minutes) || (starttime..endtime).cover?(event.endtime - 1.minutes)
          errors[:base] << "PCG is not available at this time slot!!"
          return
        end
      end
    end
  end

  def update_events(events, event)
    event_series.attributes = event
    result = event_series.save
    if result
      events.each do |e|
        begin
          old_start_time, old_end_time = e.starttime, e.endtime
          e.attributes = event
          if event_series.period.downcase == 'monthly' or event_series.period.downcase == 'yearly'
            new_start_time = make_date_time(e.starttime, old_start_time)
            new_end_time   = make_date_time(e.starttime, old_end_time, e.endtime)
          else
            new_start_time = make_date_time(e.starttime, old_end_time)
            new_end_time   = make_date_time(e.endtime, old_end_time)
          end
        rescue
          new_start_time = new_end_time = nil
        end
        if new_start_time and new_end_time
          e.starttime, e.endtime = new_start_time, new_end_time
          e.save
        end
      end
    end
    [result, event_series.errors.full_messages.to_sentence]
  end

  def assigned_path_name
    a = ""
    link = ""
    name = "Assignee Deleted by Admin"
    return a if status == "available"
    case item_type
    when "CareGiver"
      if(pcg_assigned_event.care_client)
        link = "/calendar/care_client/#{pcg_assigned_event.care_client.id}/index?year=#{cc_event.starttime.year.to_s}&month=#{(cc_event.starttime.month-1).to_s}&day=#{cc_event.starttime.day}"
        name = pcg_assigned_event.care_client.fullname
        return "<a data-no-turbolink='true' href='#{link}'>#{name}</a>"
      end
    when "CareClient"
      if(cc_assigned_event.care_giver)
        link = "/calendar/care_giver/#{cc_assigned_event.care_giver.id}/index?year=#{pcg_event.starttime.year.to_s}&month=#{(pcg_event.starttime.month-1).to_s}&day=#{pcg_event.starttime.day}"
        name = cc_assigned_event.care_giver.fullname
        return "<a data-no-turbolink='true' href='#{link}'>#{name}</a>"
      end
    end
    name
  end

   # blue: #b5e7ff
  # dark red: #ff7e7e
  # light red: #ffb2ac
  # dark green : #9be19b
  # light green: #cfeba7
  # orange: #ffc794
  # light-orange: #e9e0b2
  # grey: #cdcdcd

  def color
    case status
    when "available"
      get_color_code("#ff7e7e", '#cdcdcd')
    when "closed"
      color_code_late("#ffc794", '#b5e7ff')
    when "checked_in", "checked_out", "continue"
      DateTimeCompare.is_past?(endtime, get_zone) ? "#e9e0b2" : "#cfeba7"
      # starttime.past? ? "#e9e0b2" : "#cfeba7"
    when "submitted"
      "#9be19b"
    end
  end

  def item_type_status
    class_type = Object.const_get(item_type.classify)
    class_type.find(item_id).status
  end

  def work_status_color
    case status
    when "closed"
      DateTimeCompare.is_fifteen_mins_past?(starttime, get_zone) ? "orange" : ""
    when "checked_in", "continue", "checked_out"
      "light_green"
    when "submitted"
      "dark_green"
    end
  end

  def cc_status_color
    case status
    when "closed"
      DateTimeCompare.is_fifteen_mins_past?(starttime, get_zone) ? "orange" : ""
      # "orange"
    when "checked_in", "continue", "checked_out"
      "light_green"
    when "available"
      "light_red"
     when "submitted"
      "dark_green"
    end
  end

  def is_edit
    can_edit = (!(DateTimeCompare.is_past?(starttime, get_zone)) && ["#cdcdcd", "#b5e7ff"].include?(color))
     can_edit ? 1 : 0
  end

  def update_status text
    self.status = text
    self.save(validate: false)
  end
  
  # event in current day and within 1 hour of current time.
  def event_current_day?
    one_hour_before = false
    current_day = DateTimeCompare.compare_two_dates(starttime.strftime("%F"), DateTime.now.convert_to(get_zone).strftime("%F"), :==)
    if current_day
      time_now = Time.parse(DateTime.now.convert_to(get_zone).strftime("%F %H:%M:%S"))
      event_time = Time.parse((starttime-1.hour).strftime("%F %H:%M:%S"))
      one_hour_before = true if time_now >= event_time
    end
    one_hour_before
    # parse_for_compare(starttime).strftime("%F") == parse_for_compare(DateTime.now.convert_to(get_zone)).strftime("%F")
  end

  # allow checkin only for current day.
  def event_checkin_pass?
    if status == "closed"
      event_current_day?
    elsif ["checked_in","checked_out","continue"].include?(status)
      one_hour_before = false
      time_now = Time.parse(DateTime.now.convert_to(get_zone).strftime("%F %H:%M:%S"))
      event_time = Time.parse((starttime-1.hour).strftime("%F %H:%M:%S"))
      one_hour_before = true if time_now >= event_time
    else
      false
    end
  end

  # Splitup PCG Event nased on CC requirement
  def splitup_events care_client_event
    return self if care_client_event.starttime == starttime && care_client_event.endtime == endtime
    pcg_event_dup = dup
    destroy
    first_set = create_splitup_event(starttime, care_client_event.starttime, pcg_event_dup)
    second_set = create_splitup_event(care_client_event.starttime, care_client_event.endtime, pcg_event_dup)
    third_set = create_splitup_event(care_client_event.endtime, endtime, pcg_event_dup)
    second_set
  end

  # Splitup event on vacation
  def splitup_event_on_vacation start_time, end_time
    reload
    destroy and return if start_time == starttime && end_time == endtime
    event_dup = dup
    destroy
    first_set = create_available_splitup_events(starttime, start_time, event_dup)
    second_set = create_available_splitup_events(start_time, end_time, event_dup)
    third_set = create_available_splitup_events(end_time, endtime, event_dup)
  end

  # TODO : remove Once Cyril confirmed
  # def is_past?
  #   parse_for_compare(starttime) <= parse_for_compare(DateTime.now.convert_to(get_zone))
  # end

  def get_color_code(if_color, else_color)
    # is_past? ? if_color : else_color
    DateTimeCompare.is_past?(endtime, get_zone) ? if_color : else_color
  end

  def color_code_late(if_color, else_color)
    DateTimeCompare.is_fifteen_mins_past?(starttime, get_zone) ? if_color : else_color
  end

  def parse_for_compare(a)
    DateTime.parse("#{a.hour}:#{a.min}:#{a.sec}, #{a.day}-#{a.month}-#{a.year}")
  end

  def care_giver_phone
    item.mobile_no
  end

  def care_giver_mail
    item.user.email
  end

  def care_company_mail
    item.care_giver_company.user.email
  end

  def care_giver_company
    item.care_giver_company
  end

  def get_consecutive_splitup_events
    top_event = item.events.where('endtime = :end_time and status = :stats and is_split_up = true', end_time: starttime, stats: "available").first
    bottom_event = item.events.where('starttime = :start_time and status = :stats and is_split_up = true', start_time: endtime, stats: "available").first
    [top_event, bottom_event]
  end

  private

  def make_date_time(original_time, difference_time, event_time = nil)
    DateTime.parse("#{original_time.hour}:#{original_time.min}:#{original_time.sec}, #{event_time.try(:day) || difference_time.day}-#{difference_time.month}-#{difference_time.year}")
  end

  def create_splitup_event start_time, end_time, pcg_event_dup
    event = pcg_event_dup.dup
    event.starttime = start_time
    event.endtime = end_time
    event.all_day = false
    event.is_split_up = true
    event.save
    event
  end

  def create_available_splitup_events start_time, end_time, pcg_event_dup
    event = pcg_event_dup.dup
    event.starttime = start_time
    event.endtime = end_time
    event.status = "available"
    event.on_vacation = false
    event.all_day = false
    event.save
    event
  end

  def destroy_assigned_event
    case item_type
    when "CareClient"
      if cc_assigned_event
        pcg_event = cc_assigned_event.pcg_event
        pcg_event.update_status "available"
      end
    when "CareGiver"
      if pcg_assigned_event
        cc_event = pcg_assigned_event.cc_event
        cc_event.update_status "available"
      end
    else
      errors[:base] << "Something Went Wrong, Comming into else case!!"
      return false
    end
  end
end
