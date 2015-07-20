class CareClient < ActiveRecord::Base

  belongs_to :country
  belongs_to :state
  belongs_to :care_giver_company
  belongs_to :user, dependent: :destroy

  has_many :care_clients_givers
  has_many :care_givers, through: :care_clients_givers
  accepts_nested_attributes_for :user

  has_many :care_clients_services
  has_many :services, through: :care_clients_services
  has_many :service_trackers

  has_many :events, as: :item
  has_many :event_series, as: :item
  has_many :assigned_events

  validates :first_name, :presence => true
  validates :last_name, :presence => true
  validates :dob, :presence => true
  validates :country_id, :presence => true
  validates :state_id, :presence => true
  validates :mobile_no, :presence => true, :length => {:minimum => 10, :message => "is too short (minimum 10 characters)"}
  validates_numericality_of :mobile_no, :message => "Should be number with no space or hyphen"
  validates :telephone, :presence => true, :length => {:minimum => 10, :message => "is too short (minimum 10 characters)"}
  validates_numericality_of :telephone, :message => "Should be number with no space or hyphen"
  validates_numericality_of :telephony_no, :message => "Should be number with no space or hyphen", :allow_blank => true
  validates :zip, :presence => true
  validates :gender, :presence => true
  validates :city, :presence => true
  validates :address_1, :presence => true
  validates :medical_record_number, :uniqueness => true, :allow_nil => true, :allow_blank => true

  geocoded_by :full_address
  after_validation :geocode, :if => (:address_1_changed? || :address_2_changed? || :city_changed?)


  before_save :merge_names

  after_update :remove_future_appointment_on_deactive
  before_destroy :remove_future_appointments

  def full_address
    address_1+","+address_2+","+city
  end

  def merge_names
    self.name = first_name.strip+" "+last_name.strip+" "+last_name.strip+" "+first_name.strip
  end

  def self.search(search)
    if search
      where('LOWER(name) LIKE ?', "%#{search.downcase}%")
    else
      scoped
    end
  end

  def status_change(status)
    case(status)
    when "Active"
      self.status = "Deactive"
      self.save(validate: false)
      user = self.user
      user.approved = false
      user.save(validate: false)
    when "Deactive"
      self.status = "Active"
      self.save(validate: false)
      user = self.user
      user.approved = true
      user.save(validate: false)
    else
      self.status = "Deactive"
      self.save(validate: false)
      user = self.user
      user.approved = false
      user.save(validate: false)
    end
  end

  def current_event_status
    return "" if events.empty?
    current_events = events.where("starttime <= ? and endtime >= ?" ,DateTimeCompare.current_date_time(get_time_zone),DateTimeCompare.current_date_time(get_time_zone))
    current_events.empty? ? "" : current_events[0].cc_status_color
  end

  #To combine last name and first name
  def fullname
    first_name.to_s + " " + last_name.to_s
  end

  def get_services(slice_count)
    service_hash = Hash.new
    categories = services.where('option != ?', "N/A").collect(&:service_category).uniq.sort
    client_service_ids = care_clients_services.where('option != ?', "N/A").collect(&:service_id)
    categories.each do |cat|
      service_array = cat.services.select{|s| client_service_ids.include?(s.id)}.sort_by{|service| service.name}
      service_hash[cat.name] = service_array.each_slice(slice_count).to_a
    end
    service_hash
  end

  def self.list_care_clients(search,sort_column,sort_direction,page)
    unless sort_column == "care_givers"
      search(search).order(sort_column + ' ' + sort_direction).page(page).per(10)
    else
      self.sort_by_care_giver(page,sort_direction,search)
    end
  end

  def care_givers_count
    care_givers = self.care_givers
    return care_givers.length
  end

  def self.sort_by_care_giver(page,direction,search)
    if direction == "asc"
      Kaminari.paginate_array(self.search(search).sort_by(&:care_givers_count)).page(page).per(10)
    elsif direction == "desc"
      Kaminari.paginate_array(self.search(search).sort_by(&:care_givers_count).reverse).page(page).per(10)
    end
  end

  def register(params, company_id, is_valid = true)
    self.care_giver_company_id = company_id
    if save(validate: is_valid)
      self.user.add_role :fcg
      true
    else
      false
    end
  end

  def available_care_givers_at_timeslots_backup(start_time, end_time)
    caregivers = []
    cc_ids = []
    pcg_ids =  care_giver_ids
    return caregivers if pcg_ids.nil?
    start_day = start_time.beginning_of_day
    end_day = end_time.end_of_day
    events = Event.where('starttime  >= :start_time and endtime <= :end_time and on_vacation = :on_vacation', start_time: start_day, end_time: end_day, on_vacation: false)
    cg_events = events.select{|event| pcg_ids.include?(event.item_id) && event.item_type == "CareGiver" }
    cg_events = cg_events.select{ |e| e.starttime <= start_time and e.endtime >= end_time }
    tmp_cg_events = cg_events
    cg_events = tmp_cg_events.collect do |cg_event|
      cg_event.cc_events.each do |cc_event|
        if (cc_event.starttime..cc_event.endtime).cover?(start_time + 1.minutes) || (event.starttime..event.endtime).cover?(endtime - 1.minutes)
          cg_events.delete(cg_event.id)
        end
      end
    end
    cg_events.collect{|event| caregivers << event.item}
    caregivers.uniq
  end

  def available_care_givers_at_timeslots(start_time, end_time)
    caregivers = []
    pcg_ids = care_givers.where(status: "Active").collect(&:id)
    return caregivers if pcg_ids.nil?
    start_day = start_time.beginning_of_day
    end_day = end_time.end_of_day
    events = Event.where('starttime  >= :start_time and endtime <= :end_time and status = :status and on_vacation = :on_vacation', start_time: start_day, end_time: end_day, status: 'available', on_vacation: false)
    events = events.select{|event| pcg_ids.include?(event.item_id) && event.item_type =="CareGiver" }
    events = events.select{|e| e.starttime <= start_time and e.endtime >= end_time}
    events.collect{|event| caregivers << event.item}
    caregivers.uniq
  end

  #Auto assigning of PCG to all available events of CC
  def auto_assign
    unassigned_cc_events = []
    assigned_cc_events = []
    summary = {}
    available_events = events.where('status = ? and starttime > ? and endtime < ?',"available", DateTimeCompare.current_date_time(get_time_zone), (DateTime.now + 1.year))
    notice = "No cc events available for assignment" if  available_events.empty?
    available_events.each do |cc_event|
      available_pcgs = available_care_givers_at_timeslots(cc_event.starttime, cc_event.endtime)
      unless available_pcgs.empty?
        care_giver = preffered_care_giver(available_pcgs)
        pcg_events = care_giver.available_events_at_timeslots(cc_event.starttime, cc_event.endtime)
        pcg_event = pcg_events[0].splitup_events(cc_event)
        assigned_event = assigned_events.create(care_giver_id: care_giver.id, cc_event_id: cc_event.id,
                                                pcg_event_id: pcg_event.id)
        if assigned_event
          assigned_cc_events << cc_event
          pcg_event.update_attributes(status: "closed")
          cc_event.update_attributes(status: "closed")
        else
          unassigned_cc_events << cc_event
        end
      else
        unassigned_cc_events << cc_event
      end
    end
    summary[:failed_events], summary[:successful_events] = unassigned_cc_events.sort_by {|a| a.starttime}, assigned_cc_events.sort_by {|a| a.starttime}
    summary
  end

  #Find care giver for aasignement according to client preference
  #TO DO Need to select pcg according to preference
  def preffered_care_giver care_givers
    care_givers.first
  end

  def is_private_record?
    self.care_giver_company.is_private_record
  end

  def time_zone
    zone = care_giver_company.admin_time_zone if care_giver_company
    (zone.nil? or zone.empty?)  ? "Eastern Time (US & Canada)" : care_giver_company.admin_time_zone
  end

  def admin_email
    care_giver_company.user.email
  end

  def get_time_zone
    care_giver_company.get_time_zone if care_giver_company
  end

  def remove_future_appointment_on_deactive
    if status == "Deactive"
      remove_future_appointments_when_deactivated
    end
  end

  def remove_future_appointments_when_deactivated
    event_lists = events.where('starttime  >= :start_time and status != :submit_status', start_time: DateTimeCompare.current_date_time(get_time_zone), submit_status: "submitted")
    event_lists.each do |event|
      event.cc_assigned_event.destroy if event.cc_assigned_event
    end
  end

  # removes future appointments and currently active appointments.
  def remove_future_appointments
    event_lists = events.where('starttime  >= :start_time and status != :submit_status', start_time: DateTimeCompare.current_date_time(get_time_zone), submit_status: "submitted")
    event_lists.each do |event|
      event.cc_assigned_event.destroy if event.cc_assigned_event
    end
    active_event_lists = events.where(status: ["checked_in","continue","checked_out"])
    active_event_lists.each do |event|
      event.cc_assigned_event.destroy if event.cc_assigned_event
    end
  end
end
