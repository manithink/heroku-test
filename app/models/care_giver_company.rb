class CareGiverCompany < ActiveRecord::Base

  belongs_to :subscription_type
  belongs_to :package_type
  belongs_to :company_type
  belongs_to :organisation_type
  has_many :service_categories, dependent: :destroy
  has_many :services, dependent: :destroy
  has_one :admin_setting, dependent: :destroy  
  has_many :care_givers, dependent: :destroy
  has_many :care_clients, dependent: :destroy
  has_one :care_plan_setting, dependent: :destroy
  has_many :care_clients_services, dependent: :destroy
  belongs_to :user, dependent: :destroy
  accepts_nested_attributes_for :user

  validates :company_name, :presence => true, :length => { :minimum => 3, :maximum => 40 }
  validates :pcgc_country, :presence => true
  validates :pcgc_state, :presence => true
  validates :address_1, :presence => true
  validates :city, :presence => true
  validates :zip, :presence => true
  validates :phone, :presence => true, :length => {:minimum => 10, :message => "is too short (minimum 10 characters)"}
  validates_numericality_of :phone, :message => "Should be number with no space or hyphen"
  validates_numericality_of :alt_phone, :message => "Should be number with no space or hyphen", allow_blank: true

  validates_numericality_of :fax, :message => "Should be number with no space or hyphen", allow_blank: true
  validates :year_founded, numericality: true, :allow_blank => true, :length => { :minimum => 4, :maximum => 4 }
  validates :admin_first_name, :presence => true
  validates :admin_last_name, :presence => true
  validates :admin_phone, :presence => true, :length => {:minimum => 10, :message => "is too short (minimum 10 characters)"}
  validates_numericality_of :admin_phone, :message => "Should be number with no space or hyphen"

  validates :package_type_id, :presence => true
  validates :subscription_type_id, :presence => true
  validates :company_type_id, :presence => true
  validates :website, :allow_blank => true, :format => {:with => /\A[www]+[A-Za-z0-9._%+-]+\.[A-Za-z]+\z/}
  validates :alt_email, :allow_blank => true, :format => {:with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i}
  EXCLUDED_COMPANY_NAMES = %w(Farcare)
  validates_exclusion_of :company_name, :in => EXCLUDED_COMPANY_NAMES, :message => "not allowed.Choose another name."

  before_create :save_custom_url
  after_create :create_care_plan_setting
  after_update :update_reminderalert_job

  def admin_fullname
    admin_first_name + " " + admin_last_name
  end

  def save_custom_url
    company_custom_url = company_name.downcase.gsub(" ","_")
    company_custom_url = company_custom_url+ self.user.id.to_s
    self.create_admin_setting(custom_url: company_custom_url)
  end

  def update_reminderalert_job
    options = {change_admin_time_zone: admin_time_zone != admin_time_zone_was}
    p "---------------------------------------"
    p admin_time_zone
    p admin_time_zone_was
    UpdateAlertreminderWorker.perform_at(10.seconds.from_now, id, options)
  end

  def create_care_plan_setting
    care_plan_setting = CarePlanSetting.new
    care_plan_setting.care_giver_company_id = self.id
    care_plan_setting.save(validate: false)
  end

  def self.search(search)
    if search
      where('LOWER(company_name) LIKE ?', "%#{search.downcase}%")
    else
      scoped
    end
  end

  def active_caregivers_count
    self.care_givers.where('status != ? OR status is NULL', "Deactive").length
  end

  def active_caregivers
    self.care_givers.where('status != ? OR status is NULL', "Deactive").order(first_name: :asc)
  end

  # checks for check in alert activated by company admin
  def alert_check_in_required?
    status = false
    if care_plan_setting.farcare_tracker_used
      status = true if care_plan_setting.pcga_appointment_missed_alert_required == "true"
    end
    status
  end

  # checks for check in reminder activated by company admin
  def reminder_check_in_required?
    status = false
    if care_plan_setting.farcare_tracker_used
      status = true if care_plan_setting.pcg_checkin_reminder_required == "1"
    end
    status
  end

  # checks for check out alert activated by company admin
  def alert_check_out_required?
    status = false
    if care_plan_setting.detect_late_checkout
      status = true if care_plan_setting.pcga_checkout_alert_required == "1"
    end
    status
  end

  # checks for check out reminder activated by company admin
  def reminder_check_out_required?
    status = false
    if care_plan_setting.detect_late_checkout
      status = true if care_plan_setting.pcg_checkout_reminder_required == "1"
    end
    status
  end

  def check_in_alert_time
    care_plan_setting.pcga_appointment_missed_alert_time.to_f.minutes
  end

  def check_in_reminder_time
    care_plan_setting.pcg_checkin_reminder_time.to_f.minutes
  end

  def check_out_alert_time
    care_plan_setting.pcga_checkout_alert_time.to_f.hours
  end

  def check_out_reminder_time
    care_plan_setting.pcg_checkout_reminder_time.to_f.hours
  end


  def self.list_pcgc(column,search,page,direction)
    if column == "package_type"
      care_giver_companies = self.joins(:package_type).where('company_name != ?',"Farcare").search(search).order("package_types.name"+ ' ' + direction).page(page).per(10)
    elsif self.column_names.include? column
      care_giver_companies = self.where('company_name != ?',"Farcare").search(search).order(column + ' ' + direction).page(page).per(10)
    elsif column == "company_type"
      care_giver_companies = self.joins(:company_type).where('company_name != ?',"Farcare").search(search).order("company_types.name"+ ' ' + direction).page(page).per(10)
    elsif column == "active_care_clients"
      care_giver_companies = self.sort_by_active_care_client(page,direction,search)
    elsif column == "active_care_givers"
      care_giver_companies = self.sort_by_active_caregivers(page,direction,search)
    end
    care_giver_companies
  end

  def status_change(status)
    new_status, is_approved = "Deactive", 0 if status == "Active"
    new_status, is_approved = "Active", 1 if status == "Deactive"
    update_attributes(status: new_status)
    user.approved = is_approved
    user.save(validate: false)
  end

  def active_care_clients_count
    care_clients = self.care_clients.where("status != ? OR status is NULL", "Deactive")
    return care_clients.length
  end

  def active_care_clients
    care_clients = self.care_clients.where("status != ? OR status is NULL", "Deactive").order(first_name: :asc)
    return care_clients
  end

  def self.sort_by_active_care_client(page,direction,search)
    if direction == "asc"
      Kaminari.paginate_array(CareGiverCompany.where('company_name != ?',"Farcare").search(search).sort_by(&:active_care_clients_count)).page(page).per(10)
    elsif direction == "desc"
      Kaminari.paginate_array(CareGiverCompany.where('company_name != ?',"Farcare").search(search).sort_by(&:active_care_clients_count).reverse).page(page).per(10)
    end
  end

  def self.sort_by_active_caregivers(page,direction,search)
    if direction == "asc"
      Kaminari.paginate_array(CareGiverCompany.where('company_name != ?',"Farcare").search(search).sort_by(&:active_caregivers_count)).page(page).per(10)
    elsif direction == "desc"
      Kaminari.paginate_array(CareGiverCompany.where('company_name != ?',"Farcare").search(search).sort_by(&:active_caregivers_count).reverse).page(page).per(10)
    end
  end

  def users
    users = care_clients.collect(&:user) +  self.care_givers.collect(&:user) +[user]
    users.compact
  end

  def include_user? user
    users.collect(&:id).include?(user.id)
  end

  def isActive?
    status == "Active" ? true : false
  end

  def available_care_givers_at_timeslots(start_time, end_time)
    care_givers.joins(:events).where('starttime  >= :start_time and endtime <= :end_time', start_time: start_time, end_time: end_time)
  end

  def get_time_zone
    (admin_time_zone.nil? or admin_time_zone.empty?)  ? "Eastern Time (US & Canada)" : admin_time_zone
  end
end
