class CareClientPolicy
  attr_reader :user, :care_client

  def initialize(user, care_client)
    @user = user
    @care_client = care_client
  end

  def care_client_services?
  	pcg_access?
  end

  def edit?
  	if user.has_role? :pcg
  		pcg_access?
  	else
  		user.has_role? :pcga and care_client.care_giver_company.id.equal?(user.care_giver_company.id)
  	end
  end

  def current_care_client_events?
  	pcg_access?
  end

  def change_status?
  	pcga_can_access_events?
  end

  def delete_care_client?
  	pcga_can_access_events?
  end

  def view_services?
  	pcga_can_access_events?
  end

  def care_client_services?
    pcg_access?
  end

  def pcg_access?
  	user.has_role? :pcg and user.care_giver.care_clients.include?(care_client)
  end

  def pcga_can_access_events?
    user.has_role? :pcga and user.care_giver_company.care_client_ids.include?(care_client.id)
  end
end
