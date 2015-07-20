class VacationManagement < ActiveRecord::Base
  belongs_to :care_giver
  validate :validate_timings, :only_one_vacation_for_pcg
  validates :reason, :presence => true
  before_save :set_day

  after_update :change_events_based_on_status

  def self.get_vacations_with_start_and_end_date(start_time, end_time)
    start_time = Time.at(start_time.to_i).to_formatted_s(:db)
    end_time = Time.at(end_time.to_i).to_formatted_s(:db)
    where('startdate  >= :start_time and enddate <= :end_time', start_time: start_time, end_time: end_time)
  end

  def self.get_event_json(event_lists)
    events = []
    event_lists.each do |event|
      events << { id: event.id,
                  title: event.reason,
                  start: event.startdate.iso8601,
                  end: event.enddate.iso8601,
                  status: event.status,
                  allDay: event.all_day,
                  color: check_color(event),
                  comments: event.comments,
                  is_past: check_is_past(event)
                  }
    end
    events
  end

  def self.check_color(event)
    status = event.status
    zone = get_vacation_zone(event.care_giver_id)
    current_date_time = parse_for_vac_compare(DateTime.now.convert_to(zone))
    if(DateTimeCompare.is_past?(event.startdate, zone))
      color = '#FF0000'
    else
      case status
      when 'pending'
        color = '#CCA300';
      when 'accepted'
        color = '#009999';
      when 'rejected'
        color = '#7A5229';
      end
    end
  end

  def self.check_is_past(event)
    zone = CareGiver.find(event.care_giver_id).get_time_zone
    zone = get_vacation_zone(event.care_giver_id)
    current_date_time = parse_for_vac_compare(DateTime.now.convert_to(zone))
    if(DateTimeCompare.is_past?(event.startdate, zone))
      is_past = true
    else
      is_past = false
    end
  end

  def set_day
    if self.all_day
      self.startdate = self.startdate.beginning_of_day
      self.enddate = self.enddate.end_of_day
    end
  end

  def validate_timings
    zone = get_zone
    current_date_time = parse_for_compare(DateTime.now.convert_to(zone))
    if (startdate.nil? or enddate.nil?)
      errors[:base] << "Invalid Date !"
    elsif (startdate >= enddate) and !all_day
      errors[:base] << "Start Time must be less than End Time"
    elsif DateTimeCompare.is_past?(startdate, zone) or DateTimeCompare.is_past?(startdate, zone)
      errors[:base] << "Not allow to create past events"
    elsif (enddate.to_date.mjd - startdate.to_date.mjd ) > 12
      errors[:base] << "Not allow to create vacation more than 12 days"
    end
  end

  def get_zone
    CareGiver.find(self.care_giver_id).get_time_zone
  end

  def self.get_vacation_zone(id)
    CareGiver.find(id).get_time_zone
  end

  def only_one_vacation_for_pcg
    care_giver = CareGiver.find(self.care_giver_id)
    start_day = startdate.beginning_of_day
    end_day = enddate.end_of_day
    vacations = care_giver.vacation_managements.where('startdate  >= :start_time and enddate <= :end_time', start_time: start_day, end_time: end_day)
    vacation_lists = vacations.delete_if{|vacation| vacation.id == self.id }
    enddate = all_day ? end_day : self.enddate
    vacation_lists.each do |vacation|
      if (vacation.startdate..vacation.enddate).cover?(startdate+1.minutes) || (vacation.startdate..vacation.enddate).cover?(enddate - 1.minutes) || (startdate..enddate).cover?(vacation.startdate + 1.minutes) || (startdate..enddate).cover?(vacation.enddate - 1.minutes)
        errors[:base] << "Vacations are already requested at this time slot!!"
        return
      end
    end
  end

  def change_events_based_on_status
    case status
    when "accepted"
      change_events_appointments(true)
    when "rejected"
      change_events_appointments(false)
    end
  end

  def change_events_appointments(vacation)
    start_week = startdate.beginning_of_week(start_day = :sunday) - 1.week
    end_week = enddate.end_of_week(start_day = :sunday) + 1.week
    event_lists = care_giver.events.where('starttime  >= :start_time and endtime <= :end_time', start_time: start_week, end_time: end_week)
    event_lists.each do |event|
      if (event.starttime..event.endtime).cover?(startdate+1.minutes) || (event.starttime..event.endtime).cover?(enddate-1.minutes) || (startdate..enddate).cover?(event.starttime+1.minutes) || (startdate..enddate).cover?(event.endtime-1.minutes)
        event.on_vacation = vacation
        event.save(validate: false)
        if vacation && event.pcg_assigned_event
          event.pcg_assigned_event.change_event_status
          event.pcg_assigned_event.remove_worker_from_queue
          event.pcg_assigned_event.delete
        end
        event.splitup_event_on_vacation(startdate, enddate) if vacation
      end
    end
  end

  def self.parse_for_vac_compare(a)
    DateTime.parse("#{a.hour}:#{a.min}:#{a.sec}, #{a.day}-#{a.month}-#{a.year}")
  end

  def parse_for_compare(a)
    DateTime.parse("#{a.hour}:#{a.min}:#{a.sec}, #{a.day}-#{a.month}-#{a.year}")
  end

end
