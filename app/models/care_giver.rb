class CareGiver < ActiveRecord::Base

  belongs_to :country
  belongs_to :state
  belongs_to :care_giver_company
  belongs_to :user, dependent: :destroy

  has_many :care_clients_givers
  has_many :care_clients, through: :care_clients_givers
  has_many :event_series, as: :item
  has_one :check_inout_alert, dependent: :destroy

  accepts_nested_attributes_for :user

  before_save :merge_names
  after_create :create_check_inout_alert_setting

  has_many :service_trackers
  has_many :events, as: :item
  has_many :assigned_events
  has_many :vacation_managements

  validates :first_name, :presence => true
  validates :last_name, :presence => true
  validates :address_1, :presence => true
  validates :country_id, :presence => true
  validates :state_id, :presence => true
  validates :city, :presence => true
  validates :mobile_no, :presence => true, :length => {:minimum => 10, :message => "is too short (minimum 10 characters)"}
  validates_numericality_of :mobile_no, :message => "Should be number with no space or hyphen"
  validates :alternative_no, :length => {:minimum => 10, :message => "is too short (minimum 10 characters)"}, allow_blank: true
  validates_numericality_of :alternative_no, :message => "Should be number with no space or hyphen", allow_blank: true
  validates_numericality_of :telephony_id, :message => "Should be number with no space or hyphen", allow_blank: true
  validates :zip, :presence => true
  validates :gender, :presence => true
  validates :dob, :presence => true
  validates :emergency_phone_no1, :allow_blank => true, :length => {:minimum => 10, :message => "is too short (minimum 10 characters)"}
  validates :emergency_phone_no2, :allow_blank => true, :length => {:minimum => 10, :message => "is too short (minimum 10 characters)"}
  validates_numericality_of :emergency_phone_no1, :message => "Should be number with no space or hyphen", allow_blank: true
  validates_numericality_of :emergency_phone_no2, :message => "Should be number with no space or hyphen", allow_blank: true

  accepts_nested_attributes_for :user

  before_save :merge_names

  after_update :remove_future_appointment_on_deactive
  before_destroy :remove_future_appointments

  def self.search(search)
    if search
      where('LOWER(name) LIKE ?', "%#{search.downcase}%")
    else
      scoped
    end
  end

  def merge_names
    self.name = first_name.strip+" "+last_name.strip+" "+last_name.strip+" "+first_name.strip
  end

  def create_check_inout_alert_setting
    check_in_out_alert = CheckInoutAlert.new
    check_in_out_alert.care_giver_id = self.id
    check_in_out_alert.save(validate: false)
  end

  #To combine last name and first name
  def fullname
    first_name.to_s + " " + last_name.to_s
  end

  def self.list_care_givers(search,sort_column,sort_direction,page)
    unless sort_column == "clients"
      search(search).order(sort_column + ' ' + sort_direction).page(page).per(10)
    else
      self.sort_by_care_client(page,sort_direction,search)
    end
  end

  def care_clients_count
    care_clients = self.care_clients
    return care_clients.length
  end

  def self.sort_by_care_client(page,direction,search)
    if direction == "asc"
      Kaminari.paginate_array(self.search(search).sort_by(&:care_clients_count)).page(page).per(10)
    elsif direction == "desc"
      Kaminari.paginate_array(self.search(search).sort_by(&:care_clients_count).reverse).page(page).per(10)
    end
  end

  def change_status
    new_status, is_approved = "Deactive", 0 if status == "Active"
    new_status, is_approved = "Active", 1 if status == "Deactive"
    update_attributes(status: new_status)
    user.approved = is_approved
    user.save(validate: false)
  end

  def available_events_at_timeslots(start_time, end_time)
    start_day = start_time.beginning_of_day
    end_day = end_time.end_of_day
    event_lists = events.where('starttime  >= :start_time and endtime <= :end_time', start_time: start_day, end_time: end_day)
    event_lists.select{|e| e.starttime <= start_time and e.endtime >= end_time}
  end

  def time_zone
    zone = care_giver_company.admin_time_zone
    (zone.nil? or zone.empty?)  ? "Eastern Time (US & Canada)" : care_giver_company.admin_time_zone
  end

  def get_time_zone
    care_giver_company.get_time_zone
  end

  def checked_out_completely?
   not_checkedout_count =  assigned_events.where("status = ? OR status = ?","checked_in","continue").count
   not_checkedout_count.zero?
  end

  def checked_out_completely_authorisation?(id)
    assigned_event = AssignedEvent.find id
    assigned_event_not_checked_out = (assigned_events.where("status = ? OR status = ?","checked_in","continue"))[0]
    if assigned_event_not_checked_out
      if assigned_event_not_checked_out.id == id
        true
      elsif assigned_event.cc_event.status == "closed"
        checked_out_completely? 
      else
        true
      end
    else
      true
    end
  end

  def get_unchecked_assigned_event_id
    not_checkedout_assigned_events = assigned_events.where("status = ? OR status = ?","checked_in","continue")
    id = not_checkedout_assigned_events[0].id unless not_checkedout_assigned_events.empty?
  end

  def email_notification_required?
    check_inout_alert.send_mail
  end

  def sms_notification_required?
    check_inout_alert.send_sms
  end

  def current_work_status
    return "" if events.empty?
    current_events = events.where("starttime <= ? and endtime >= ?" ,DateTimeCompare.current_date_time(get_time_zone),DateTimeCompare.current_date_time(get_time_zone))
    p "==========Current Working Status=================="
    current_events.empty? ? "" : current_events[0].work_status_color
  end

  def remove_future_appointment_on_deactive
    if status == "Deactive"
    	remove_future_appointments
    end
  end

  def location_missing_alert_required?
    required = care_giver_company.care_plan_setting.pcga_gps_mismatch_alert_required == "1" ? true : false
  end

  def remove_future_appointments
    event_lists = events.where('starttime  >= :start_time', start_time: DateTimeCompare.current_date_time(get_time_zone))
    event_lists.each do |event|
      event.pcg_assigned_event.destroy if event.pcg_assigned_event
    end
  end
end
