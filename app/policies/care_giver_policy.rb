class CareGiverPolicy
  attr_reader :user, :care_giver

  def initialize(user, care_giver)
    @user = user
    @care_giver = care_giver
  end


  def new?
    user.has_role? :pcga
  end

  def create?
    user.has_role? :pcga
  end

  def edit?
    admin_can_access?
  end

  def settings_view_profile?
    pcg_access?
  end

  def settings_change_password?
    pcg_access?
  end

  def index?
    pcg_access?
  end

  def current_care_client_events?
    pcg_access?
  end

  def invite_family?
    user.has_role? :pcga
  end

  def report?
    user.has_role? :pcga
  end

  def change_status?
    pcga_can_access_events?
  end

  def delete_care_giver?
    pcga_can_access_events?
  end

  def settings_check_in_out_alerts?
    user.has_role? :pcga and user.care_giver_company.care_giver_ids.include?(care_giver.id)
  end

  def pcg_access?
    user.has_role? :pcg and care_giver.user.id.equal?(user.id)
  end

  def pcga_can_access_events?
    user.has_role? :pcga and user.care_giver_company.care_giver_ids.include?(care_giver.id)
  end

  def admin_can_access?
    (user.has_role? :pcga and user.care_giver_company.care_giver_ids.include?(care_giver.id)) or user.has_role? :admin
  end


end
