class AssignedEventPolicy
  attr_reader :user, :assigned_event

  def initialize(user, assigned_event)
    @user = user
    @assigned_event = assigned_event
  end

  def view_my_services?
  	user.has_role? :pcg and assigned_event.care_giver.id.equal?(user.care_giver.id)
  end

  def edit_my_services?
  	user.has_role? :pcg and assigned_event.care_giver.id.equal?(user.care_giver.id) and assigned_event.cc_event.event_checkin_pass? and assigned_event.care_giver.checked_out_completely_authorisation?(assigned_event.id)
  end

  def view_care_client_services?
  	user.has_role? :pcg and assigned_event.care_giver.id.equal?(user.care_giver.id) and assigned_event.cc_event.event_checkin_pass? and assigned_event.care_giver.checked_out_completely_authorisation?(assigned_event.id)
  end

  def view_care_plan?
  	user.has_role? :pcg and assigned_event.care_giver.id.equal?(user.care_giver.id)
  end

end