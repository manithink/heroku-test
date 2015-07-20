class EventSeries < ActiveRecord::Base
  attr_accessor :title, :description, :commit_button, :weekdays

  validates :frequency, :period, :presence => true

  validates :weekdays, presence: true, if: :is_weekly?

  validate :validate_timings, :only_one_event_series_for_pcg

  validate :valid_upto_datetime


  has_many :events, :dependent => :destroy

  belongs_to :item, polymorphic: true

  after_create :create_events_until_end_time

  before_save :change_starttime_endtime_for_allday

  WEEKDAYS = {0 => "Sun", 1 => "Mon", 2 => "Tue", 3 => "Wed", 4 => "Thu", 5 => "Fri", 6 => "Sat"}


  def create_events_until_end_time(end_time = RECURRING_EVENTS_UPTO)
    old_start_time   = starttime
    old_end_time     = endtime
    frequency_period = recurring_period(period)
    new_start_time, new_end_time = old_start_time, old_end_time
    range = (upto.change({:hour => starttime.hour,  :min => starttime.min, :sec => starttime.sec }) + frequency.send(frequency_period))
    range = range.end_of_week(start_day = :sunday) if period == "Weekly"

    while frequency.send(frequency_period).from_now(old_start_time) <= range
      if(period.downcase == 'weekly')
        weekdays_array = weekdays.collect(&:to_i)
        week_begin = old_start_time.beginning_of_week(start_day = :sunday)
        week_end = old_start_time.end_of_week(start_day = :sunday)
        Range.new(week_begin.to_i, week_end.to_i).step(1.day) do |seconds_since_epoch|
          week_start = Time.at(seconds_since_epoch).change({:hour => starttime.hour,  :min => starttime.min, :sec => starttime.sec }).to_s(:db)
          week_end = Time.at(seconds_since_epoch).change({:hour => endtime.hour,  :min => endtime.min, :sec => endtime.sec }).to_s(:db)
          if (starttime..upto).cover?(week_start) && weekdays_array.include?(Time.at(seconds_since_epoch).wday)
            attributes = {:title => title, :description => description,
                          :all_day => all_day, :starttime => week_start,
                          :endtime => week_end, :item_id => item_id,
                          :item_type => item_type}
            p create_event(attributes)
          end
        end
      else
        attributes = {:title => title, :description => description,
                      :all_day => all_day, :starttime => new_start_time,
                      :endtime => new_end_time, :item_id => item_id,
                      :item_type => item_type}
        create_event(attributes) unless new_start_time.nil?
      end

      new_start_time = old_start_time = frequency.send(frequency_period).from_now(old_start_time)
      new_end_time   = old_end_time   = frequency.send(frequency_period).from_now(old_end_time)

      if period.downcase == 'monthly' or period.downcase == 'yearly'
        begin
          new_start_time = make_date_time(starttime, old_start_time)
          new_end_time   = make_date_time(endtime, old_end_time)
        rescue
          new_start_time = new_end_time = nil
        end
      end
    end
  end

  def is_weekly?
    period == "Weekly"
  end

  def create_event(attributes)
    self.events.create(attributes)
  end

  def recurring_period(period)
    Event::REPEATS.key(period.titleize).to_s.downcase
  end

  def frequency_text
    ActionController::Base.helpers.pluralize(frequency, Event::DUP_REPEATS[Event::REPEATS.values.index(period)])
  end

  def change_starttime_endtime_for_allday
    if self.all_day
      self.starttime = self.starttime.beginning_of_day
      self.endtime = self.endtime.end_of_day
    end
  end

  def valid_upto_datetime
    errors[:base] << "Upto must be a valid datetime" if upto.nil?
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


  def only_one_event_series_for_pcg
    if item_type == 'CareGiver'
      care_giver = CareGiver.find item_id
      start_day = starttime.beginning_of_day
      end_day = endtime.end_of_day
      event_lists = care_giver.events.where('starttime  >= :start_time and endtime <= :end_time', start_time: start_day, end_time: end_day)
      event_lists = event_lists.delete_if{|event| event.event_series_id == id }
      event_lists.each do |event|
        if (event.starttime..event.endtime).cover?(starttime+1.minutes) || (event.starttime..event.endtime).cover?(endtime - 1.minutes) || (starttime..endtime).cover?(event.starttime + 1.minutes) || (starttime..endtime).cover?(event.endtime - 1.minutes)
          errors[:base] << "PCG is not available at this time slot!!"
          return
        end
      end
    end
  end


  def self.testing
    es = EventSeries.last
    p es
    old_start_time   = es.starttime
    old_end_time     = es.endtime
    frequency_period = es.recurring_period(es.period)
    new_start_time, new_end_time = old_start_time, old_end_time
    range = (es.upto.change({:hour => es.starttime.hour,  :min => es.starttime.min, :sec => es.starttime.sec }) + es.frequency.send(frequency_period))
    while es.frequency.send(frequency_period).from_now(old_start_time) <= range
      week_begin = old_start_time.beginning_of_week - 1.days
      week_end = old_start_time.end_of_week - 1.days

      Range.new(week_begin.to_i, week_end.to_i).step(1.day) do |seconds_since_epoch|
        if (es.starttime..es.upto).cover?(Time.at(seconds_since_epoch)) && [2, 4].include?(Time.at(seconds_since_epoch).wday)
          p Time.at(seconds_since_epoch)
          p Time.at(seconds_since_epoch).wday
        end
      end
      new_start_time = old_start_time = es.frequency.send(frequency_period).from_now(old_start_time)
      new_end_time   = old_end_time   = es.frequency.send(frequency_period).from_now(old_end_time)

    end
  end

  def parse_for_compare(a)
    DateTime.parse("#{a.hour}:#{a.min}:#{a.sec}, #{a.day}-#{a.month}-#{a.year}")
  end

  private

  def make_date_time(original_time, difference_time)
    DateTime.parse("#{original_time.hour}:#{original_time.min}:#{original_time.sec}, #{original_time.day}-#{difference_time.month}-#{difference_time.year}")
  end
end
